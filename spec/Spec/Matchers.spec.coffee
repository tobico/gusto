Spec.describe 'Spec.Matchers', ->
  describe 'be', ->
    subject 'be', -> Spec.Matchers.be

    it 'matches when values are the same', ->
      @be(true)(true).result.should equal true

    it "doesn't match when values are different", ->
      @be(true)(false).result.should equal false

    it 'displays a message with comparison of values', ->
      @be(true)(false).text().should equal "be true, actual false"

  describe 'beA', ->
    subject 'beA', -> Spec.Matchers.beA

    context 'Boolean', ->
      subject 'beABoolean', -> @beA Boolean

      it 'matches for a boolean', ->
        @beABoolean(true).result.should equal true

      it 'matches for a boolean object', ->
        @beABoolean(new Boolean(true)).result.should equal true

      it "doesn't match for another primitive", ->
        @beABoolean(0).result.should equal false

      it "doesn't match for an object", ->
        @beABoolean({foo: 'bar'}).result.should equal false

    context 'Function', ->
      subject 'beAFunction', -> @beA Function

      it 'matches for a function', ->
        @beAFunction(->).result.should equal true

      it "doesn't match for a primitive", ->
        @beAFunction(0).result.should equal false

      it "doesn't match for a non-function object", ->
        @beAFunction({foo: 'bar'}).result.should equal false

    context 'Number', ->
      subject 'beANumber', -> @beA Number

      it 'matches for a primitive number', ->
        @beANumber(5).result.should equal true

      it 'matches for a number object', ->
        @beANumber(new Number(5)).result.should equal true

      it "doesn't match for another primitive", ->
        @beANumber(true).result.should equal false

      it "doesn't match for an object", ->
        @beANumber({foo: 'bar'}).result.should equal false

    context 'String', ->
      subject 'beAString', -> @beA String

      it 'matches for a primitive string', ->
        @beAString('banana').result.should equal true

      it 'matches for a string object', ->
        @beAString(new String('banana')).result.should equal true

      it "doesn't match for another primitive", ->
        @beAString(true).result.should equal false

      it "doesn't match for an object", ->
        @beAString({foo: 'bar'}).result.should equal false

    context 'Object', ->
      subject 'beAnObject', -> @beA Object

      it 'matches for an object', ->
        @beAnObject({foo: 'bar'}).result.should equal true

      it "doesn't match for a primitive", ->
        @beAnObject(true).result.should equal false

      it "matches for an objectified primitive", ->
        @beAnObject(new Boolean(true)).result.should equal true

  describe 'equal'
  describe 'include'
  describe 'throwError'
  describe 'beAn'
