Seaweed - A coffeescript testing framework
==========================================

Overview
--------

Seaweed lets you write behavioral tests for your Coffeescript.
It's inspired by rspec, and features a handy command-line spec runner.

Comparison
----------

  * [Jasmine](https://github.com/pivotal/jasmine-gem)
    -- integrates well with Rails, limited command-line support,
    no built-in Coffeescript support
  * [Evergreen](https://github.com/jnicklas/evergreen)
    -- uses Jasmine and has good Coffeescript support,
    no support for nested file structures
  * __Seaweed__
    -- native support for Coffeescript, clean syntax for assertions and stubs,
    no support for plain JavaScript, command-line autotest mode

Installation
------------

Seaweed uses Culerity to run your Coffeescript, as such it can only run using JRuby.

    sudo jruby -S gem install seaweed

Project structure
-----------------

Seaweed expects your Coffeescript source code to be in `.coffee` files,
within a `lib` directory, and your specs to be in `.spec.coffee` files
within a `specs` directory.

You can override these locations by creating a configuration file in
`seaweed.yml` or `config/seaweed.yml`.

Here's an example configuration for a Rails project using [barista](https://github.com/Sutto/barista):

    libs:
      - app/coffeescripts
    specs:
      - spec/coffeescripts

Writing Specs
-------------

Create a `.spec.coffee` file under `specs` for each test case.
    
    #require ST/Model
    
    Spec.describe "Model", ->
      beforeEach ->
        ST.class 'TestModel', 'Model', -> null
        @model = ST.TestModel.create()
    
      describe "#scoped", ->
        it "should return a new scope", ->
          scope = ST.TestModel.scoped()
          scope.should beAnInstanceOf(ST.Model.Scope)

Specifications
--------------

`describe` and `context` blocks break up and organize your tests, and `it`
blocks define individual tests. `beforeEach` blocks are run before each `it`
block in the current `describe` or `context` block, allowing you to do setup
before your test runs.

Assertions
----------

Assertions are placed inside an `it` block, and can be made on an extended
object with `.should` and `.shouldNot`, and on a non-extended object
(such as null or undefined, or the base object) using `expect(object).to`
and `expect(object).notTo`

Extended Objects
----------------

By default, Seaweed extends the following objects with methods `.should`,
`.shouldNot`, `.shouldReceive` and `.shouldNotReceive`:

  * Array
  * Boolean
  * Date
  * Function
  * Number
  * RegExp
  * String
  * Element
  * jQuery
  * SpecObject

The base type `Object` is not extended, as this causes a vast number of bugs
in jQuery.

If you want to create an extended object, you can use the SpecObject class:

    myObject = new SpecObject(name: 'Eric')
    myObject.should beAnInstanceOf SpecObject

You can also extend your own classes using `Spec.extend`. This extends both
the class prototype (accessible in instances of the class), and the class
object itself.

    Person = (name) ->
        @name = name
        this
    Spec.extend Person
    
    eric = new Person('Eric')
    eric.shouldReceive 'spectacles'
    eric.spectacles 'blackRimmed'

Matchers
--------

Matchers are paired with assertions to define your specs,
e.g. `bike.color.should equal('red')`

  * `equal(expectedValue)`
    Compares actual value with expected value using `==`
  * `be(expectedValue)`
    Compares actual value with expected value using `===`
  * `beAFunction`
    Tests if value is a function
  * `beAString`
    Tests if value is a string
  * `beANumber`
    Tests if value is a number
  * `beABoolean`
    Tests if value is a boolean
  * `beAnObject`
    Tests if value is an object (but not a function, string, number or boolean)
  * `beTrue` and `beFalse`
    Tests if value is boolean true or boolean false
  * `beAnInstanceOf(expectedClass)`
    Tests if value is an instance of expected class
  * `include(values)`
    Tests if an object or an array includes the specified value(s).
    (values can be an object, an array, or a single string/boolean/number)
  * `haveHtml(html)`
    Tests if a jQuery element has the given HTML. HTML is parsed by the
    browser before comparison, so that things like tag attributes don't have to
    be in the same order to match.

Stubs
-----

You can stub any method of an extended object using `#shouldReceive`:

    Spec.describe "Dog", ->
      it "should do a trick", ->
        @dog.shouldReceive 'jump'
        @dog.giveTreat()

Check the arguments passed to stub methods with `.with`:

    @dog.shouldReceive('jump').with(2, 'meters')

Return a value with `.andReturn`:

    @dog.shouldReceive('jump').andReturn('woof!')
    console.log @dog.jump() # 'woof!'

If stubbing over an existing method, you can cause the original method to run in addition using `.andPassthrough`

    @car.shouldReceive('brake').andPassthrough()
    
You can also use `.shouldNotReceive` to assert that a method not be called:

    @car.shouldNotReceive('crash')

Expectations
------------

`shouldReceive` creates an expectation, and you can create one yourself using `expectation(message)`:

    exp = expectation("callback method called")
    callback = -> exp.meet()

By default, an expectation raises an error at the end of the block unless it has been met exactly once. You can change this using `.exactly`:

    @bell.shouldReceive('ring').exactly(3).times

The `times` at the end is only there for readability, it shouldn't be called with `()`.

`.shouldNotReceive(name)` is syntactic sugar for `.shouldReceive(name).exactly(0).times`.

Requires
--------

Seaweed automatically loads all of your specs, but loads only the lib files
that are required, using the [Sprockets library](https://github.com/sstephenson/sprockets).

You specify which files are required to run a script using `#= require`
processor directives:

    #= require jquery
    #= require jquery-ui
    #= require backbone
    #= require_tree .

Spec Runner
-----------

Run specs with the `seaweed` command.

    jruby -S seaweed [mode]

The default mode is `auto`, which uses [watchr](https://github.com/mynyml/watchr) to monitor files for changes, and automatically reruns your tests when your code changes.

The `terminal` mode lets you run tests only once, for use with continuous integration tools.

The `server` mode starts only the built in Sinatra server, allowing you to run tests manually through your browser of choice.