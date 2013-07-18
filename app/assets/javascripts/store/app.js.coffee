@app = window.app ? {Models: {}, Views: {}, Collection: {}}

jQuery ->
  @app = window.app ? {Models: {}, Views: {}, Collection: {}}
  _.templateSettings = {
    interpolate: /\<\@\=(.+?)\@\>/g,
    evaluate: /\<\@(.+?)\@\>/g
  }

  #  ADDRESS
  class Address extends Backbone.Model

  class ShippingTitleView extends Backbone.View
    'el': '#shipping_address'
    'events':
      'click a': 'showForm'

    initialize: ->
      _.bindAll(@, 'render')

    showForm: (e)->
      @.$el.closest('div.address_outer').find('form').show()

  @app.Views.ShippingTitle  = ShippingTitleView

  class Address extends Backbone.Model
    url: '/checkout/update/address',
    fullAddress: ->
      @get('firstname') + @get('lastname') + ',' +  @get('address1') + ', ' + @get('city')

  @app.Models.Address  = Address

  class Addresses extends Backbone.Collection
    model: Address

  @app.Collection.Addresses  = Addresses

  class AddressesView extends Backbone.View
    'el': '#checkout_form_address'

    initialize:->
      _.bindAll(@, 'render')
      @collection.on('add', @addOne, @)

    events:
      'click .new_address input': 'showAddressForm'
#      'submit': 'saveAddress'

    render: ->
      @collection.each(@addOne, @)
      @

    saveAddress:(e)->
#      e.preventDefault()

      data = Backbone.Syphon.serialize(@).order.ship_address_attributes
      if data.id == '' || typeof(data.id) == 'undefined'
        address = new window.app.Models.Address()
        address.set(data)
        @collection.add(address)
        address.save()
      else
        address = @collection.get(parseInt(data.id))
        address.set(data)
        address.save()

      @hideAddressForm()
      $(@el).hide()
      $(@el).closest('.address_outer').find('.current_address').html(address.fullAddress())

    addOne: (model) ->
      addressView = new AddressView({model: model})
      @.$el.find('table.address_list').prepend(addressView.render().$el)

    emptyValue:->
      @.$el.find('.address_input').find('input[type=text]').each(@empty)
      @.$el.find('.address_input').find('input[type=tel]').each(@empty)
      @.$el.find('.address_input').find('#order_ship_address_attributes_id').val('')
    empty: (index, el)->
     $(el).val('')

    hideAddressForm: (e) ->
      @emptyValue()
      @.$el.find('.address_input').hide()

    showAddressForm: (e)->
      @emptyValue()
      @.$el.find('.address_input').show()

  @app.Views.Addresses  = AddressesView

  class AddressView extends Backbone.View
    'tagName': 'tr'
    'template': _.template($("#line_address").html())
    'events':
      'click td .edit': 'fillData',
      'click td input[type=radio]': 'hideFormInput'

    initialize: ->
      _.bindAll(@, 'render')
      @model.on('change', @render, @)

    render: ->
      @.$el.html(@template(@model.toJSON()))
      if @model.get('is_current')
       @.$el.find('input[type=radio]').prop('checked', true)
      @

    addressInput:->
      @.$el.closest('#checkout_form_address').find('.address_input')
    hideFormInput:(e)->
      @fillData()
      @addressInput().hide()

    showFormInput:(e)->
      @addressInput().show()

    address: ->
      @model.get('address')

    selectRadioButton: ->
      @.$el.find('input').prop('checked', true)

    fillData: (e)->
      @selectRadioButton()
      @showFormInput()
      @addressInput().find('#order_ship_address_attributes_firstname').val(@model.get('firstname'))
      @addressInput().find('#order_ship_address_attributes_lastname').val(@model.get('lastname'))
      @addressInput().find('#order_ship_address_attributes_address1').val(@model.get('address1'))
      @addressInput().find('#order_ship_address_attributes_city').val(@model.get('city'))
      @addressInput().find('#order_ship_address_attributes_zipcode').val(@model.get('zipcode'))
      @addressInput().find('#order_ship_address_attributes_phone').val(@model.get('phone'))
      @addressInput().find('#order_ship_address_attributes_id').val(@model.get('id'))

  @app.Views.Address  = AddressView

  new @app.Views.ShippingTitle
  collectionData = $('.address_outer').data('address')
  newCollect = _.map(collectionData, (c) -> c.address)
  addresses = new app.Collection.Addresses(newCollect)
  addressesView = new app.Views.Addresses({collection:addresses})
  addressesView.render()

  # Address END
  class ShippingMethodTitleView extends Backbone.View
    'el': '#shipping_method'
    'events':
      'click a': 'showForm'

    initialize: ->
      _.bindAll(@, 'render')

    showForm: (e)->
      @.$el.closest('div.deliver_outer').find('form').show()

  @app.Views.ShippingMethodTitle  = ShippingMethodTitleView

  new @app.Views.ShippingMethodTitle

