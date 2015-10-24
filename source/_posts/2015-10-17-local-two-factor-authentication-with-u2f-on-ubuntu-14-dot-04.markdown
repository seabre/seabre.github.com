---
layout: post
title: "Local Two-Factor Authentication With U2F On Ubuntu 14.04"
date: 2015-10-17 21:21:26 -0400
comments: true
categories: u2f security linux ubuntu pam authentication yubikey yubico
---

I received my GitHub-themed U2F Yubikey this week. [U2F](https://en.wikipedia.org/wiki/Universal_2nd_Factor) is an open, standardized protocol for allowing people to authenticate with a device. It hasn't been around long, but there are already [strong efforts](https://www.yubico.com/why-yubico/for-individuals/github/) to get people to use it.

If you've used the Google Authenticator app,  you'll see the utility of a U2F key as it's much smaller than a smartphone. Getting it to work is as simple as inserting the key and pressing a button.
A majority of implementations, and there aren't many, are web services like Google and GitHub. [Yubico](https://www.yubico.com/) has produced a [pam-u2f](https://developers.yubico.com/pam-u2f/) module that allows you to hook in U2F authentication to PAM. PAM is what Linux uses to allow adding and customizing various authentication mechanisms.

## Very Important Note - Proceed This Guide At Your Own Risk

If you are worried about potentially locking yourself out of your machine, **do not continue**.

**There is the very real risk of locking yourself out of your machine following this guide.** 

**I have not tested scenarios with a fully-encrypted disk or with an encrypted home directory.**

**Proceed at your own risk.**

## Getting Started

Adding U2F to Ubuntu 14.04 is actually straightforward. The documentation for the PAM module is dense, so that's where this article comes in. These instructions could work with Debian, but I haven't tried.


First, you need to add Yubico's package repo:

```
sudo add-apt-repository ppa:yubico/stable
sudo apt-get update
```

Then, you need to install the relevant packages:

```
sudo apt-get install pam-u2f pamu2fcfg
```

Now we need to install some rules for Linux's device manager so it can deal with the U2F keys:

```
sudo wget -O /etc/udev/rules.d/70-u2f.rules https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules
```

After this, you should reboot your machine.

## Registering Your Key

When your machine starts up again, we need to setup the locations that will hold our keys:

```
mkdir ~/.yubico ~/.config/Yubico
touch ~/.config/Yubico/u2f_keys
ln -s ~/.config/Yubico/u2f_keys ~/.yubico/u2f_keys
```

The latest versions of pam-u2f read from `~/.config/Yubico/u2f_keys` while the current version in the Ubuntu repository reads from `~/.yubico/u2f_keys`. With this method, the actual key is stored in `~/.config/Yubico`. The symbolic link in `~/.yubico/u2f_keys` points to `~/.config/Yubico/u2f_keys`. I set it up this way because I do not know what will happen when Yubico updates what is in the Ubuntu repository!

Next, we need to tell the system about the key we want to register. We will use the `pamu2fcfg` tool to do that.


Insert your U2F key and run `pamu2fcfg -umyusername` where `myusername` is your account's username. It should recognize your key. When it does, press the button on your key. It will generate a code that looks like this:

```
myusername:oijoij3o4ijfoi3j4ifj3o4jfiojewlkjflksjefw4g4g34gr34g34-g34g3-4g34g34g34g3,9043809584309850943284023023024230009809809898a09898098b
```

Now, fire up a text editor and copy the text `pamu2fcfg` generated and place it in `~/.config/Yubico/u2f_keys`. Very important note: If you use zsh, you may see a percent sign at the end. Do not include that!

## Configuring PAM

Now it's time to setup PAM to use your U2F key. What we want to do is require the U2F key for authentication every single time you enter your password.

Located in `/etc/pam.d/common-auth` are the particular rules for handling this. Mine before I added the U2F rules looked like this:

```
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
auth  [success=1 default=ignore]  pam_unix.so nullok_secure
# here's the fallback if no module succeeds
auth  requisite     pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth  required      pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth  optional      pam_cap.so
# end of pam-auth-update config
```

To get U2F working, we need to open `/etc/pam.d/common-auth` in a text editor. Add this line at the end of the file: `auth sufficient pam_u2f.so debug cue`

With that addition, it should look like this:

```
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
auth  [success=1 default=ignore]  pam_unix.so nullok_secure
# here's the fallback if no module succeeds
auth  requisite     pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth  required      pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth  optional      pam_cap.so
# end of pam-auth-update config

# u2f
auth sufficient pam_u2f.so debug cue
```

After you do this reboot. When your computer boots back up again. Place your U2F key in a USB slot. Type in your password and login. Your U2F key should blink. Touch the button on your U2F key and it should log you in.

**WARNING**: If your U2F key **did not blink** or pressing the blinking button on your U2F **did not** log you in, **do not continue this guide**. 

The `sufficient` option in our U2F PAM config above allows us to not require the key, but we can still *use* the key optionally.


Let's test the U2F key on `sudo` after we login. Open up a terminal, insert your U2F key and type `sudo ls`. It will ask you for your password. After you enter your password you should see a bunch of text. At the end you should see something like:

```
[../util.c:get_devices_from_authfile(140)] Length of key number 1 is 65
[../util.c:get_devices_from_authfile(166)] Found 1 device(s) for user seabre
[../util.c:do_authentication(219)] Device max index is 0
[../util.c:do_authentication(242)] Attempting authentication with device number 1
```

If you do, you'll see your key blinking. Press the button on your U2F key. It should authenticate you and run the `ls` command.

**WARNING**: **Do not continue** if your key did not blink after you entered your password. **You probably won't be able to log in to your machine if you follow the instructions after this point.**

If you did see your key blink after you entered your password and were able to touch your key to access your machine, feel free to continue beyond this point. However, proceed with caution. You can now change the U2F options in your PAM config to `auth required pam_u2f.so cue`

So now your `/etc/pam.d/common-auth` should look like this:

```
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
auth  [success=1 default=ignore]  pam_unix.so nullok_secure
# here's the fallback if no module succeeds
auth  requisite     pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth  required      pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth  optional      pam_cap.so
# end of pam-auth-update config

# u2f
auth required pam_u2f.so cue
```

After this change, you will need to reboot. After you reboot, try logging in without your key. You will notice that it will tell you your password is wrong. Try again, but first insert your U2F key. Enter your password as usual and press enter. You should see your U2F key blinking. Press the button on your U2F key. You should now be logged in.

## Recommendations

### Get A Second U2F Key

If you intend to require U2F for login, what happens if you lose your key? You won't be able to get in. Get a second key, register it, then put it in a safe place. Yubico [describes](https://developers.yubico.com/pam-u2f/) the format of `u2f_keys`:

```
<username>:<KeyHandle1>,<UserKey1>:<KeyHandle2>,<UserKey2>:...
```

So you can run `pamu2fcfg` with your second key and follow the format to add it to `u2f_keys` described above.

### Consider Full Disk Encryption

As far as I know, you won't be able to do this if you've installed Ubuntu without it already. But, doing this makes it less possible to bypass two-factor authentication.
