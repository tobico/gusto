Spec.extend Spec.ExpectationError, Spec.PendingError, Spec

Spec.describe 'Spec.ExpectationError', ->
  subject 'error', -> new Spec.ExpectationError()
  it -> should beAn Error

Spec.describe 'Spec.PendingError', ->
  subject 'error', -> new Spec.PendingError()
  it -> should beAn Error
  its 'status', -> should equal Spec.Report.Pending

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
      @spec.environmentExtended = true
      @spec.shouldNotReceive('extendEnvironment')
      @spec.describe(@title, @definition)

    it 'loads a new suite', ->
      @spec.describe(@title, @definition)
      @spec.suites.length.should equal 1
      @spec.suites[0].should beA Spec.Suite

  describe '.extend', ->
    given 'prototype',  -> {}
    given 'object',     -> {prototype: @prototype}

    before ->
      Spec.extend @object

    it 'extends object with ObjectDSL', ->
      for key, value of Spec.ObjectDSL
        @object[key].should be value

    it 'extends prototype with ObjectDSL', ->
      for key, value of Spec.ObjectDSL
        @prototype[key].should be value

  describe '.extendEnvironment', ->
    given 'root', -> {}
    before ->
      @spec.environmentExtended = false
      @spec.root = @root
      @spec.extendEnvironment = Spec.extendEnvironment

    it 'sets environmentExtended', ->
      @spec.stub 'extend'
      @spec.extendEnvironment()
      @spec.environmentExtended.should equal true

    it 'extends root with DSL', ->
      @spec.stub 'extend'
      @spec.extendEnvironment()
      for key, value of Spec.DSL
        expect(@root[key]).to be value

    it 'extends root with Matchers', ->
      @spec.stub 'extend'
      @spec.extendEnvironment()
      for key, value of Spec.Matchers
        expect(@root[key]).to be value

    it 'extends basic set of classes', ->
      @spec.shouldReceive('extend').with(
        Array,
        Boolean,
        Date,
        Function,
        Number,
        RegExp,
        String,
        @root,
        Element,
        jQuery,
        Spec.MockObject
      )
      @spec.extendEnvironment()
