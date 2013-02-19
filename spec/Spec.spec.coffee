Spec.extend Spec

Spec.describe 'Spec', ->
  subject 'spec', ->
    mock()

  describe 'describe', ->
    before ->
      @spec.describe = Spec.describe
      @spec.stub 'reportTestResult'

    it 'initializes the environment if not initialized', ->
      @spec.EnvironmentInitialized = false
      @spec.shouldReceive('initializeEnvironment')
      @spec.describe()

