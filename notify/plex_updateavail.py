#!/usr/bin/python

"""

PlexPy > Settings > Notifications > Script > Script Arguments: 
       -ver {update_version} -url {update_url} -distro {update_distro} -extrainfo {update_extra_info} -added {update_changelog_added} -fixed {update_changelog_fixed}

"""

from email.mime.text import MIMEText
import email.utils
import smtplib
import sys
import os
import argparse
from ConfigParser import ConfigParser
from shutil import copyfile

if os.path.exists('/opt/custom/notify/email.ini') == False:
 print("\nMail settings not defined!")
 print("Please review and edit /opt/custom/notify/email.ini\n")
 copyfile('/opt/custom/notify/.email.ini.dist', '/opt/custom/notify/email.ini')
 exit()

parser = argparse.ArgumentParser()
parser.add_argument('-ver', action='store', default='_version_',
                    help='The update version')
parser.add_argument('-url', action='store', default='http://downloadlink.goes.here',
                    help='The update download URL')
parser.add_argument('-distro', action='store', default='_distro_',
                    help='The distribution of the PMS server')
parser.add_argument('-extrainfo', action='store', default='',
                    help='The extra information for the update')
parser.add_argument('-added', action='store', default='',
                    help='The features added in this update')
parser.add_argument('-fixed', action='store', default='',
                    help='The list of bug fixes included')
a = parser.parse_args()

# Email settings
config = ConfigParser()
config.read('/opt/custom/notify/email.ini')
name = config.get('Email','DISPLAY_NAME')
sender = config.get('Email','FROM_ADDRESS')
to = config.get('Email','TO_ADDRESS')
email_server = config.get('Email','MAIL_SERVER')
email_port = config.get('Email','MAIL_PORT')
email_tls = config.get('Email','USE_TLS')
email_auth = config.get('Email','SMTP_AUTH')
email_username = config.get('Email','SMTP_USER')
email_password = config.get('Email','SMTP_PASS')

email_subject = 'Plex Update Available'

msg_html = """\
<html>
<head></head>

<body>
    <p style="font-family: Arial, Helvetica, sans-serif; font-size=9px">A Plex update is available - {a.ver} ({a.distro})<br>
       Download at <a href="{a.url}" target="_new">{a.url}</a></p>
"""

if a.extrainfo:
 msg_html += "<p style=\"font-family: Arial, Helvetica, sans-serif; font-size=9px;\">{a.extrainfo}</p>"

if a.added:
 msg_html += "<p style=\"font-family: Arial, Helvetica, sans-serif; font-size=9px;\">Added:<pre>{a.added}</pre></p>"

if a.fixed:
 msg_html += "<p style=\"font-family: Arial, Helvetica, sans-serif; font-size=9px;\">Fixed:<pre>{a.fixed}</pre></p>"

msg_html += "</body></html>"

msg_html = msg_html.format(a=a)

# Send mail
message = MIMEText(msg_html, 'html')
message['Subject'] = email_subject
message['From'] = email.utils.formataddr((name, sender))
message['To'] = email.utils.formataddr((to, to))

mailserver = smtplib.SMTP(email_server, email_port)
if email_tls == "yes":
 mailserver.starttls()
mailserver.ehlo()
if email_auth == "yes":
 mailserver.login(email_username, email_password)
mailserver.sendmail(sender, to, message.as_string())
mailserver.quit()

