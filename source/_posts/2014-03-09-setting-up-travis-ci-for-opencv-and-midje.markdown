---
layout: post
title: "Setting Up Travis CI for OpenCV and Midje"
date: 2014-03-09 20:56
comments: true
categories: clojure travis-ci testing opencv midje 
---

I’ve been fiddling with [OpenCV](http://opencv.org) for a few weeks. Using OpenCV and Clojure is straightforward. The hardest part was setting up OpenCV.

When I’m experimenting and I get to a place where I feel like I know what I’m doing, I’ll start writing tests. Eventually you'll setup continuous integration, but then you remember how difficult installing OpenCV was! If you’d like to use Travis CI with your Clojure project using OpenCV, I’ve already done the work for you! Swapping out midje isn’t a problem, if you’d rather use core.test or speclj, but I’m going to focus on midje here.

I’m assuming your project looks something like Magomimmo’s [opencv-start](https://github.com/magomimmo/opencv-start). He’s also the guy that wrote the [Clojure tutorial](http://docs.opencv.org/2.4/doc/tutorials/introduction/clojure_dev_intro/clojure_dev_intro.html) on OpenCV’s documentation site. If you setup your project using those instructions, that is fine since they are almost identical. The only difference is that I’m using a more more up to date version of OpenCV. You will have to make a few changes to the Travis CI yaml configuration below if you want to use a different version.

First, we need to add the midje and lein localrepo plugins to our project.clj if they aren’t there already. Travis CI needs to know about them. Adding the following line inside defproject within your project.clj should suffice:

```clojure
:plugins [[lein-localrepo "0.5.3"] [lein-midje "3.1.3"]]
```

Next, we need to add the `.travis.yml` config to the root of the repo:

```yaml
language: clojure
lein: lein2
script: lein2 midje
jdk:
  - oraclejdk7

compiler: 
  - gcc

before_install:
  - sudo apt-get update

install:
  - sudo apt-get install python-dev python-numpy

before_script:
  - git clone https://github.com/Itseez/opencv.git
  - cd opencv
  - git checkout 2.4
  - mkdir build
  - cd build
  - cmake ..
  - make -j8
  - sudo make -j8 install
  - cd ../..
  - mkdir -p native/linux/x86_64
  - cp opencv/build/lib/libopencv_java248.so native/linux/x86_64/libopencv_java248.so
  - cp opencv/build/bin/opencv-248.jar .
  - jar -cMf opencv-native-248.jar native
  - lein2 localrepo install opencv-248.jar opencv/opencv 2.4.8
  - lein2 localrepo install opencv-native-248.jar opencv/opencv-native 2.4.8
  - cp .tappedcv.examplesettings ~/.tappedcv
```
With this configuration, we tell Travis CI that: our project is a Clojure project, that we are using Leiningen 2.0, midje for testing, and Oracle JDK 7. The lines after that are for building OpenCV.

The lines before `before_script` tell Travis CI that: we need to use the GCC compiler, install python dev dependencies, and numpy for OpenCV. The lines in `before_script` are the actual build process automation for OpenCV. 

If you noticed that the `before_script` is similar to the build steps in Magomimmo’s tutorial, you would be right. The only change I made was to use OpenCV 2.4.8. If you’d like to use a different release, you should change the `before_script` to match your needs. On Travis CI, the build process takes about 8 minutes.
