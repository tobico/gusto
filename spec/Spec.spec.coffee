Spec.extend Spec

Spec.describe 'Spec', ->
  subject 'spec', -> mock()
  given 'dsl', -> mock(describe: null)
  before ->
    @spec.dsl = @dsl

  describe '.describe', ->
    before ->
      @spec.describe = Spec.describe
      @spec.stub 'initializeEnvironment'

    it 'initializes the environment', ->
      @spec.shouldReceive('initializeEnvironment')
      @spec.describe()

    it "doesn't initialize the environment if already initialized", ->
      @spec.EnvironmentInitialized = true
      @spec.shouldNotReceive('initializeEnvironment')
      @spec.describe()

    it 'passes through to dsl', ->
      @dsl.shouldReceive('describe').with('foo', 'bar')
      @spec.describe 'foo', 'bar'
  
  describe '.extend', ->
    before ->
      @klass                  = ->
      @instance               = new @klass
      @extensions             = mock(foo: null)
      @spec.ObjectExtensions  = @extensions
      @spec.extend            = Spec.extend
      @spec._extended         = []
      @spec.extend @klass

    it 'records class as extended', ->
      @spec._extended.should include(@klass)

    it 'extends class with ObjectExtensions as class methods', ->
      @klass.foo.should be(@extensions.foo)

    it 'extends class with ObjectExtensions as instance methods', ->
      @instance.foo.should be(@extensions.foo)
