---
layout: post
title: "A Simple Livecoding Environment For Overtone With Light Table"
date: 2013-08-31 13:08
comments: true
categories: clojure, overtone, lighttable, livecoding, music  
---

I've been using [Overtone](http://overtone.github.io/) off and on for a while, and I've been wanting to try out [Light Table](http://www.lighttable.com/), so I decided to see if I could get Overtone working with it.

Emacs is pretty much the standard for livecoding in Overtone, but it's not the most accessible environment for beginners. I actually use vim, but it's not that great, either. Light Table seems to be a good alternative, but I ran into some project dependency problems getting it setup. The fixes are easy to duplicate. After the problem is solved, it's nice.

I'm going to assume the following: you're in a Linux environment, you already have a copy of Light Table installed and working, you have [Leiningen](http://leiningen.org/) installed and working, and that you already have [SuperCollider](http://supercollider.sourceforge.net/) installed and working, which we need for Overtone.

First, let's generate a new project somewhere:

`$ lein new livecoding`

Now, add the `livecoding` project to your workspace in Light Table. If you need help doing this, check the [docs](http://docs.lighttable.com/).

Inside your `livecoding` project, you should have `project.clj`, which looks like this:

```clojure
(defproject livecoding "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]])
```

OK, great. But now we need to add Overtone. Usually, we'd just change `project.clj` to look like this:

```clojure
(defproject livecoding "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [overtone "0.8.1"]])
```

The problem with this is that Overtone has a dependency on Clojure 1.3.0, which Light Table's REPL refuses to use. We need to force Overtone to use Clojure 1.5.1. Let's fix that:

```clojure
(defproject livecoding "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [overtone "0.8.1" :exclusions [org.clojure/clojure]]
                 [org.clojure/data.json "0.2.2"]])
```

OK. So what does that do? We're forcing overtone to ignore its dependency on Clojure 1.3. We're also adding `data.json`, because Light Table's REPL appears to have a dependency on that. Now, we're good to go.

Make sure you saved the changes to `project.clj` and let's now open up `core.clj`, which should be in `src/livecoding` in our workspace.

Let's change it to this:

```clojure
(ns livecoding.core
  (:use overtone.live))
```

Now let's get the REPL going. Just press `Ctrl+Enter` to boot up Overtone. It takes a little bit to get started, but once it boots up, let's just confirm it works. Change `core.clj` to:
 
```clojure
(ns livecoding.core
  (:use overtone.live))

  (demo (sin-osc))
```

Highlight `(demo (sin-osc))` and press `Ctrl+Enter` and you should hear a simple Sine wave.
