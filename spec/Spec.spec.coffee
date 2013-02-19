Spec.extend Spec

Spec.describe 'Spec', ->
  subject 'spec', ->
    mock()

  describe 'describe', ->
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
      it 'calls the definition', ->
        called = expectation 'call the definition'
        @spec.describe 'foo', ->
          called.meet()

    context 'when not passed a definition', ->
      it 'reports the test as pending', ->
        @spec.shouldReceive('reportTestResult').with('pending')
        @spec.describe 'foo'