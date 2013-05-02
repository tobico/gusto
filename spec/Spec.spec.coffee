Spec.extend Spec

Spec.describe 'Spec', ->
  subject 'spec', -> mock()
  given 'dsl', -> mock(describe: null)
  before ->
    @spec.Suites = []
    @spec.dsl = @dsl

  describe '.describe', ->
    given 'title', -> 'foo'
    given 'definition', -> ->

    before ->
      @spec.describe = Spec.describe
      @spec.stub 'initializeEnvironment'

    it 'initializes the environment', ->
      @spec.shouldReceive('initializeEnvironment')
      @spec.describe(@title, @definition)

    it "doesn't initialize the environment if already initialized", ->
      @spec.EnvironmentInitialized = true
      @spec.shouldNotReceive('initializeEnvironment')
      @spec.describe(@title, @definition)

    it 'loads a new suite', ->
      @spec.describe(@title, @definition)
      @spec.Suites.length.should equal 1
      @spec.Suites[0].should beA Spec.Suite

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
