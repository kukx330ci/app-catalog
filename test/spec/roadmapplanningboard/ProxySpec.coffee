Ext = window.Ext4 || window.Ext

Ext.require [
  'Rally.apps.roadmapplanningboard.Proxy'
  'Rally.apps.roadmapplanningboard.Model'
  'Rally.ui.notify.Notifier'
]

describe 'Rally.apps.roadmapplanningboard.Proxy', ->

  helpers
    createRecords: ({oldValues, newValues}) ->
      field =
        name: 'field'

      model =
        getDirtyFields: -> [field]
        getDirtyCollectionFields: -> [field]

        modified:
          field: oldValues
        get: (name) ->
          newValues

      return [model]

  describe '#buildRequest', ->
    beforeEach ->
      @proxy = Ext.create 'Rally.apps.roadmapplanningboard.Proxy',
        url: ''
      @operation = params: {}

    it 'should add withCredentials to the request', ->
      expect(@proxy.buildRequest(@operation).withCredentials).toBe true

    describe 'when adding an item to collection', ->
      beforeEach ->
        @operation.records = @createRecords
          oldValues: [{id:1},{id:2},{id:3}]
          newValues: [{id:1},{id:2},{id:3},{id:4}]

      it 'should set request action to create', ->
        expect(@proxy.buildRequest(@operation).action).toBe 'create'


    describe 'when removing an item from a collection', ->
      beforeEach ->
        @operation.records = @createRecords
          oldValues: [{id:1},{id:2},{id:3}]
          newValues: [{id:1},{id:2}]

      it 'should set request action to destroy', ->
        expect(@proxy.buildRequest(@operation).action).toBe 'destroy'


  describe '#buildUrl', ->
    beforeEach ->
      @proxy = Ext.create 'Rally.apps.roadmapplanningboard.Proxy',
        url: 'foo/{fooId}/bar'
      @request = { url: '', operation:
        params:
          fooId: '123' }

    it 'should build the url and replace template items with operation parameters', ->
      expect(@proxy.buildUrl(@request)).toBe 'foo/123/bar'

  describe '#_decorateOperation', ->
    beforeEach ->
      @stub Rally.environment, 'getContext', () ->
        getWorkspace: () ->
          _refObjectUUID: '12345678-1234-1234-1234-12345678'
        getProject: () ->
          _refObjectUUID: '12345678-1234-1234-1234-12345679'
      @operation =
        allowWrite: -> false
        action: 'read'
      @proxy = Ext.create 'Rally.apps.roadmapplanningboard.Proxy',
        url: 'foo/123/bar'

    it 'should set noQueryScoping on operation when issuing request', ->
        operation = @proxy._decorateOperation(@operation, Ext.emptyFn, @)
        expect(operation.noQueryScoping).toBe true

    it 'should add workspace to operation', ->
      operation = @proxy._decorateOperation(@operation)
      expect(operation.params.workspace).toBe '12345678-1234-1234-1234-12345678'

    it 'should add project to operation', ->
      operation = @proxy._decorateOperation(@operation)
      expect(operation.params.project).toBe '12345678-1234-1234-1234-12345679'
