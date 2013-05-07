Spec.extend Spec

Spec.describe 'Spec.ExpectationError'
Spec.describe 'Spec.PendingError'

Spec.describe 'Spec', ->
  subject 'spec', -> mock()
  given 'root', -> mock(describe: null)
  before ->
    @spec.suites = []
    @spec.root = @root

  describe '.describe', ->
    given 'title', -> 'foo'
    given 'definition', -> ->

    before ->
      @spec.describe = Spec.describe
      @spec.stub 'extendEnvironment'

    it 'initializes the environment', ->
      @spec.shouldReceive('extendEnvironment')
      @spec.describe(@title, @definition)

    it "doesn't initialize the environment if already initialized", ->
      @spec.EnvironmentInitialized = true
      @spec.shouldNotReceive('extendEnvironment')
      @spec.describe(@title, @definition)

    it 'loads a new suite', ->
      @spec.describe(@title, @definition)
      @spec.suites.length.should equal 1
      @spec.suites[0].should beA Spec.Suite

  describe '.extend', ->
    before ->
      @klass          = ->
      @instance       = new @klass
      @extensions     = mock(foo: null)
      @spec.ObjectDSL = @extensions
      @spec.extend    = Spec.extend
      @spec._extended = []
      @spec.extend @klass

    it 'records class as extended', ->
      @spec._extended.should include(@klass)

    it 'extends class with ObjectDSL as class methods', ->
      @klass.foo.should be(@extensions.foo)

    it 'extends class with ObjectDSL as instance methods', ->
      @instance.foo.should be(@extensions.foo)

  describe '.initializeEnvironment'
