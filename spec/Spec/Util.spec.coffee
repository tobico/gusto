Spec.describe 'Spec.Util', ->
  describe '.extend', ->
    given 'object', -> {a: true}

    it 'adds properties from another object', ->
      Spec.Util.extend @object, {b: true}
      @object.a.should equal true
      @object.b.should equal true

    it 'adds properties from multiple objects', ->
      Spec.Util.extend @object, {b: true}, {c: true}
      @object.a.should equal true
      @object.b.should equal true
      @object.c.should equal true

    it 'returns the object', ->
      expect(Spec.Util.extend(@object, {b: true})).to be @object

  describe '.reference', ->
    context 'with a function', ->
      given 'fn', -> (-> 'foo')
      subject 'reference', -> Spec.Util.reference(@fn)

      it 'returns the function', ->
        @reference.should be @fn

    context 'with a value', ->
      given 'value', -> mock 'value'
      subject 'reference', -> Spec.Util.reference(@value)

      it 'returns a function which wraps the value', ->
        @reference.should beA Function
        @reference().should be @value

  describe '.dereference', ->
    given 'context', -> mock 'context'

    context 'with a function', ->
      given 'value', -> mock 'value'
      given 'fn', ->
        self = this
        ->
          this.should be self.context
          self.value

      it 'calls the function in context and returns result', ->
        Spec.Util.dereference(@fn, @context).should be @value

    context 'with a value', ->
      given 'value', -> mock 'value'

      it 'returns the value', ->
        Spec.Util.dereference(@value, @context).should be @value

  describe '.descriptionize', ->
    it 'formats a simple comparison', ->
      fn = -> should equal('foo')
      Spec.Util.descriptionize(fn).should equal('should equal foo')

    it 'formats camel cased names into words', ->
      fn = -> should beAnInteger()
      Spec.Util.descriptionize(fn).should equal('should be an integer')

    it 'formats something complex with logic', ->
      fn = -> should be('monkeys') if foo
      Spec.Util.descriptionize(fn).should equal('if foo it should be monkeys')

  describe '.inspect', ->
    subject 'inspect', -> Spec.Util.inspect

    it 'returns "null" for null', ->
      @inspect(null).should equal 'null'

    it 'returns "undefined" for undefined', ->
      @inspect(undefined).should equal 'undefined'

    it 'returns "true" for true', ->
      @inspect(true).should equal 'true'

    it 'returns "false" for false', ->
      @inspect(false).should equal 'false'

    it 'wraps strings in pretty quotes', ->
      @inspect('foo').should equal '“foo”'

    it 'enumerates arrays', ->
      @inspect(['foo', undefined]).should equal "[“foo”, undefined]"

    it 'enumerates direct properties of objects', ->
      @inspect(foo: 'bar', zap: true).should equal '{foo: “bar”, zap: true}'

  describe '.escape', ->
    it 'escapes text for HTML', ->
      text = '<dogs & cats>'
      html = '&lt;dogs &amp; cats&gt;'
      Spec.Util.escape(text).should equal(html)
