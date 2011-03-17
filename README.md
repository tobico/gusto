Seaweed - A coffeescript testing framework
==========================================

Overview
--------

Seaweed lets you write behavioral tests for your Coffeescript. It's inspired by rspec, and features a handy command-line spec runner.

Comparison
----------

  * [Jasmine](https://github.com/pivotal/jasmine-gem) -- integrates well with Rails, doesn't touch base Object class, limited command-line support, no built-in Coffeescript support
  * [Evergreen](https://github.com/jnicklas/evergreen) -- uses Jasmine and has good Coffeescript support, no support for nested file structures
  * __Seaweed__ -- native support for Coffeescript, clean syntax for assertions and stubs, (reversibly) extends base Object class, no support for plain JavaScript, command-line autotest mode

Installation
------------

Seaweed uses Culerity to run your Coffeescript, as such it can only run using JRuby.

    sudo jruby -S gem install seaweed

Project structure
-----------------

Seaweed expects your Coffeescript source code to be in `.coffee` files, within a `lib` directory, and your specs to be in `.spec.coffee` files within a `specs` directory.

Writing Specs
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

Specifications
--------------

`describe` and `context` blocks break up and organize your tests, and `it` blocks define individual tests. `beforeEach` blocks are run before each `it` block in the current `describe` or `context` block, allowing you to do setup before your test runs.

Assertions
----------

Assertions are placed inside an `it` block, and can be made on an object with `object.should` and `object.shouldNot`, and on a non-object (such as null or undefined) using `expect(object).to` and `expect(object).notTo`

Matchers
--------

Matchers are paired with assertions to define your specifications, (eg. `bike.color.should equal('red')`)

  * `equal(expectedValue)`
    Compares actual value with expected value using `==`
  * `be(expectedValue)`
    Compares actual value with expected value using `===`
  * `beAFunction`
    Tests if value is a function
  * `beTrue` and `beFalse`
    Tests if value is boolean true or boolean false
  * `beAnInstanceOf(expectedClass)`
    Tests if value is an instance of expected class

Stubs
-----

You can stub any method of an object using `Object#shouldReceive`:

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

Spec Runner
-----------

Run specs with the `seaweed` command.

    `seaweed [mode]`
    
The default mode is `auto`, which uses watchr to monitor files for changes, and automatically reruns your tests when your code changes.

The `terminal` mode lets you run tests only once, for use with continuous integration tools.

The `server` mode starts only the built in Sinatra server, allowing you to run tests manually through your browser of choice.