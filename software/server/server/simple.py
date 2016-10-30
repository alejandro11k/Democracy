#!/usr/bin/env python

from flask import Flask
from flask import render_template
from flask import url_for, redirect
from flask import request, session, flash
from flask.ext.wtf import Form
from wtforms import RadioField, SubmitField, validators
from subprocess import call

DEBUG = True
SECRET_KEY = """\x01X\\">\xff4^E{\xce\xe7\x9d\x91\x96\xc7t\xac`\x82\x0b\x122_"""
USERNAME = 'admin'
PASSWORD = 'default'
PUBLIC = True

BYPASS_EXEC = "/home/pi/morpheus/scripts/set-passthrough.sh"

app = Flask(__name__)
app.config.from_object(__name__)

class MorpheusForm(Form):
    bypass = RadioField(u'Audio Bypass', choices=[('on', 'On'), ('off', 'Off')])
    submit = SubmitField(u'Submit')

@app.route('/')
def root():
    form = MorpheusForm()
    return render_template('index.html', form=form)

@app.route(u'/morpheus', methods=[u'POST'])
def newlunch():
    form = MorpheusForm(request.form)
    if request.method == 'POST' and form.validate():
        #print request.form
        print form.bypass.data
        if form.bypass.data == "on":
            print "Enabling bypass"
            call([BYPASS_EXEC, "1"])
            flash('Bypass On')
        else:
            print "Disabling bypass"
            call([BYPASS_EXEC, "0"])
            flash('Bypass Off')
    return redirect(url_for('root'))

if __name__ == '__main__':
    if app.config['PUBLIC']:
        app.run(host='0.0.0.0',port=5000)
    else:
        app.run()
