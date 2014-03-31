# Gusto - A coffeescript testing framework

## Overview

Gusto lets you write behavioral tests for your Coffeescript.
It's inspired by rspec, and features an integrated command-line spec runner.

### Comparison

  * [Jasmine](https://github.com/pivotal/jasmine-gem)
    -- integrates well with Rails, limited command-line support,
    no built-in Coffeescript support
  * [Evergreen](https://github.com/jnicklas/evergreen)
    -- uses Jasmine and has good Coffeescript support,
    no support for nested file structures
  * __Gusto__
    -- native support for Coffeescript, clean syntax for assertions and stubs,
    no support for plain JavaScript, command-line autotest mode

## Setup

### Installation

To install gusto:

    gem install gusto

### Configuration

Gusto expects your Coffeescript source code to be in `.coffee` files,
within a `lib` directory, and your specs to be in `.spec.coffee` files
within a `specs` directory.

You can override these locations by creating a configuration file in
`gusto.json` or `config/gusto.json`.

Here's an example configuration for a Rails project using the Rails 3 asset pipeline:

```json
{
  "lib_paths": [
    "vendor/assets/javascripts",
    "app/assets/javascripts"
  ],
  "spec_paths": [
    "spec/javascripts"
  ]
}
```

### Sprockets extensions

You can provide custom code to run on Gusto's internal Sprockets environment.
This allows you to load up any other libraries required to compile your
assets, for example:

    // config/gusto.json
    {
        "sprockets_extensions": "config/gusto/sprockets_extensions.rb"
    }

    # config/gusto/sprockets_extensions.rb
    puts "Extending Sprockets with HandlebarsAssets"
    require 'handlebars_assets'
    append_path HandlebarsAssets.path

## Writing specs

Create a `.spec.coffee` file under `specs` for each test case.

    #= require ST/Model

    Spec.describe "Model", ->
      before ->
        @model = new Model()

      describe "#scoped", ->
        it "returns a new scope", ->
          expect(@model.scoped()).to beA Scope

### Structuring your specs

`describe`/`context` blocks break up and organize your tests, and `it`
blocks define individual tests.

`before` blocks run before any tests in the same context, and give you a place
to set up the environment for your tests:

    Spec.describe 'Employee', ->
      describe '#new', ->
        context 'with a name', ->
          before ->
            @employee = new Employee('Fred')

          it "has a name", ->
            expect(@employee.name).to equal('Fred')

### Expecting behaviour (assertions)

Use `expect` within an `it` block to specify what constitutes success:

    it 'is named Lisa', ->
      expect(@user.name).to equal 'Lisa'

    it 'is not blue', ->
      expect(@car.color).notTo equal 'Blue'

### Matchers

Matchers define what you can check with an `expect`. The following matchers
are provided as part of Gusto:

  * `equal(expectedValue)`
    Tests if values are equal by converting them both to strings and comparing
  * `be(expectedValue)`
    Tests if values are identical as-is
  * `beA(class) / beAn(class)`
    Tests that the value is, or inherits from, the specified class
  * `include(expectedValues)`
    Tests if an object or an array includes the specified value(s). (expectedValues can be an object, an array, or a single string/boolean/number)
  * `throwError(message)`
    Tests if a function causes an error to be thrown when called.

### Marking tests as pending

Leave out a tests's definition, and it's marked as pending, ready for you to fill in later

    describe '#new', ->
      it "has a name"

You can also put `pending()` at the start of a test to mark it as pending,
and optionally provide a description:

    it "calculates age and credit rating", ->
      pending("determine credit rating procedure")
      expect(@customer.ageAndCreditRating()).to equal('42 and excellent')

## Mocking and stubbing

### Mock objects

Create a mock object with `mock`:

    @switch = mock('light switch', on: true, off: true)

All arguments are optional.

### Method stubs

You can stub a method on an object using `allow().toReceive`

    it "should do a trick", ->
      allow(@dog).toReceive 'jump'
      @dog.giveTreat()

You can also require that specific arguments are provided using `.with`:

    allow(@dog).toReceive('jump').with(2, 'meters')

Specify a return a value with `.andReturn`:

    allow(@dog).toReceive('jump').andReturn('woof!')

### Expectations

Require that a stub be called using `expect`, and you'll get an error if it
isn't:

    expect(@dog).toReceive('jump')
    @dog.jump()

You can also require that a stub not be called:
  
    expect(@dog).notToReceive('jump')

Specify that a stub should be called multiple times with `.exactly(n).times`:

    expect(@bell).toReceive('ring').exactly(3).times

When you put an expectation on a method, you override the original method. You can
keep its existing behaviour with `.andPassthrough`:

    expect(@car).toReceive('brake').andPassthrough()

## Spec Runner

Run specs with the `gusto` command.

    bundle exec gusto [options] mode

The `auto` mode uses [watchr](https://github.com/mynyml/watchr) to monitor files for changes, and automatically reruns your tests when your code changes.

The `cli` mode lets you run tests only once, for use with continuous integration tools.

The `server` mode starts only the built in Sinatra server, allowing you to run
tests manually through your browser of choice.

You can abbreviate modes to their first letter, for example `gusto s` is the same as `gusto server`.

### Running partial suite

When running as a server, you can run part of your test suite by specifying
a ?filter= paramter in the URL with a keyword to filter spec file names against.

I.e. http://127.0.0.1:4567/?filter=form

## Requires

Gusto automatically loads all of your specs, but loads only the lib files
that are required, using the [Sprockets library](https://github.com/sstephenson/sprockets).

You specify which files are required to run a script using `#= require`
processor directives:

    #= require jquery
    #= require jquery-ui
    #= require backbone
    #= require_tree .

## Writing more expressive tests

Gusto has some more advanced language features you can use to make your tests
shorter and more expressive.

### Given

`given` is a shorthand way to set up your test objects.

    describe '#setEngine', ->
      given 'engine', -> new Engine()

      it 'should set engine', ->
        @car.setEngine @engine
        @car.getEngine().should be(@engine)

### Subject

`subject` sets up a special subject named `@subject`, which is automatically
used as the object to run assertions on, when not explicitly specified.

    Spec.describe 'Car', ->
      subject -> new Car()

      it -> should beAnInstanceOf(Car)

      describe '#setEngine' ->
        given 'engine', -> new Engine()
        before -> @subject.setEngine @engine

        # Automatic title: "should be running"
        it -> should 'beRunning'

### Its

`its` tests an attribute of the subject.

   Spec.describe 'Car', ->
     subject -> new Car()

     describe '#setEngine' ->
       given 'engine', -> new Engine()
       before -> @subject.setEngine @engine

       # Automatic title: "engine should be @engine"
       its('getEngine') -> should be(@engine)

       # Automatic title: "engine should not be overheated"
       its('getEngine') -> shouldNot 'beOverheated'

### Untitled Specifications

If you leave out the title from a specification, Gusto will attempt to
create one using the source code of the specification definition. This works
better for shorter specs.

    Spec.describe 'Employee', ->
      # Automatic title: "@employee name should not equal Barry"
      it -> @employee.name.shouldNot equal('Barry')

