#!/usr/bin/python

"""

PlexPy > Settings > Notifications > Script > Script Arguments: 
       -ver {update_version} -url {update_url} -distro {update_distro} -extrainfo {update_extra_info} -added {update_changelog_added} -fixed {update_changelog_fixed}

"""

from email.mime.text import MIMEText
import email.utils
import smtplib
import sys
import argparse


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
name = 'PlexPy' # Your name
sender = 'jeremysherriff@gmail.com' # From email address
to = 'alerts@bgs.co.nz'
email_server = '192.168.220.254' # Email server (Gmail: smtp.gmail.com)
email_port = 25  # Email port (Gmail: 587)
email_username = 'email' # Your email username
email_password = 'password' # Your email password
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
# mailserver.starttls()
mailserver.ehlo()
# mailserver.login(email_username, email_password)
mailserver.sendmail(sender, to, message.as_string())
mailserver.quit()

