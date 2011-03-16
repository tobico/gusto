Seaweed - A coffeescript testing framework
==========================================

Overview
--------

Seaweed lets you write behavioral tests for your Coffeescript. It's inspired by rspec, and features a handy command-line test runner.

Project structure
-----------------

Seaweed expects your Coffeescript source code to be in `.coffee` files, within the `lib` directory, and your specs to be in `.spec.coffee` files within the `specs` directory.

Writing Tests
-------------

Create a `.spec.coffee` file under `specs` for each test case.

    $ ->
      Spec.describe "Model", ->
        beforeEach ->
          ST.class 'TestModel', 'Model', -> null
          @model = ST.TestModel.create()
      
        describe "#scoped", ->
          it "should return a new scope", ->
            scope = ST.TestModel.scoped()
            scope.should beAnInstanceOf(ST.Model.Scope)

Installation
------------

Seaweed uses Culerity to run your Coffeescript, thus it requires JRuby to run.

    sudo jruby -S gem install seaweed

Usage
-----

Run tests with the `seaweed` command.

    `seaweed [mode]`
    
The default mode is `auto`, which uses watchr to monitor files for changes, and automatically reruns your tests when your code changes.

The `terminal` mode lets you run tests only once, for use with continuous integration tools.

The `server` mode starts only the built in Sinatra server, allowing you to run tests manually through your browser of choice.