{run_permutations} = require('../../test_helper')

StreamCollection = require('../../../src/internal/stream_collection').StreamCollection

class TestStream
  constructor: (@_id) ->
  id: () -> @_id

stream = new TestStream("1234")
stream2 = new TestStream("5678")


describe 'StreamCollection', () ->
  describe 'Adding one stream', ->
    coll = null

    beforeEach () -> coll = new StreamCollection()

    get_actions = (get) -> {
      update: () -> coll.update({stream: stream.id()})
      resolve: () -> coll.resolve(stream)
      get: get
    }

    run_permutations("resolve stream", get_actions (done) -> coll.get("stream").should.eventually.be.equal(stream).notify(done))
    run_permutations("reject other", get_actions (done) -> coll.get("other").should.be.rejectedWith(Error).notify(done))


  describe 'Adding two streams', ->
    coll = null

    before () ->
      coll = new StreamCollection()
      coll.update({a: stream.id(), b: stream2.id()})
      coll.resolve(stream)
      coll.resolve(stream2)

    it 'should resolve existing stream a', () ->
      return coll.get('a').should.eventually.be.equal(stream)

    it 'should resolve existing stream b', () ->
      return coll.get('b').should.eventually.be.equal(stream2)

    it 'should reject missing stream c', () ->
      return coll.get('c').should.be.rejectedWith(Error)

