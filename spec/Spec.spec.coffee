Spec.extend Spec

Spec.describe 'Spec', ->
  subject 'spec', ->
    mock()

  describe '.describe', ->
    before ->
      @spec.describe = Spec.describe
      @spec.stub 'initializeEnvironment'
      @spec.stub 'reportTestResult'

    it 'initializes the environment', ->
      @spec.shouldReceive('initializeEnvironment')
      @spec.describe()

    it "doesn't initialize the environment if already initialized", ->
      @spec.EnvironmentInitialized = true
      @spec.shouldNotReceive('initializeEnvironment')
      @spec.describe()

    context 'when passed a definition', ->
      it 'displays a new results node'

      it 'constructs a test stack', ->
        @spec.describe 'foo', ->
        expect(@spec.testStack).to beAnArray
        @spec.testStack.length.should == 1

      it 'calls the definition', ->
        called = expectation 'call the definition'
        @spec.describe 'foo', ->
          called.meet()

    context 'when not passed a definition', ->
      it 'reports the test as pending', ->
        @spec.shouldReceive('reportTestResult').with('pending')
        @spec.describe 'foo'

  describe '.descriptionize', ->
    before ->
      @spec.descriptionize = Spec.descriptionize

    it 'formats a simple comparison', ->
      fn = -> should equal('foo')
      @spec.descriptionize(fn).should equal('should equal foo')

    it 'formats camel cased names into words', ->
      fn = -> should beAnInteger()
      @spec.descriptionize(fn).should equal('should be an integer')

    it 'formats something complex with logic', ->
      fn = -> should be('monkeys') if foo
      @spec.descriptionize(fn).should equal('if foo it should be monkeys')

  describe '.escape', ->
    before ->
      @spec.escape = Spec.escape

    it 'escapes text for HTML', ->
      text = '<dogs & cats>'
      html = '&lt;dogs &amp; cats&gt;'
      @spec.escape(text).should equal(html)

  describe '.extend', ->
    before ->
      @klass = ->
      @instance = new @klass
      @extensions = {
        foo: ->
      }
      @spec.ObjectExtensions = @extensions
      @spec.extend = Spec.extend
      @spec._extended = []
      @spec.extend @klass

    it 'records class as extended', ->
      @spec._extended.should include(@klass)

    it 'extends class with ObjectExtensions as class methods', ->
      @klass.foo.should be(@extensions.foo)

    it 'extends class with ObjectExtensions as instance methods', ->
      @instance.foo.should be(@extensions.foo)
