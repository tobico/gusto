Spec.describe 'Spec.Util', ->
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

  describe '.escape', ->
    it 'escapes text for HTML', ->
      text = '<dogs & cats>'
      html = '&lt;dogs &amp; cats&gt;'
      Spec.Util.escape(text).should equal(html)
