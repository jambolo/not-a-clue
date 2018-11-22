`
import AppBar from '@material-ui/core/AppBar';
import Checkbox from '@material-ui/core/Checkbox';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormGroup from '@material-ui/core/FormGroup';
import React, { Component } from 'react';
import Tab from '@material-ui/core/Tab';
import Tabs from '@material-ui/core/Tabs';
`

GroupedCardList = (props) ->
  { selectedIds, typeId, cards } = props
  <ul>
    {(
      for id in selectedIds when cards[id].type is typeId
        <li key={id}>
          {cards[id].name}
        </li>
    )}
  </ul>

CardList = (props) ->
  { selectedIds, cards, types } = props

  <ul>
    {(
      for typeId, value of types
        <li key={typeId}>
          <b> {value.title} </b>
          <GroupedCardList selectedIds={selectedIds} typeId={typeId} cards={cards} />
        </li>
    )}
  </ul> 

class CardChoices extends Component
  changeEventHandler: (cardId) =>
    (event) =>
      @props.onChange(cardId, event.target.checked);

  render: ->
    <FormGroup row>
      {(
        for id, info of @props.cards when info.type is @props.type
          <FormControlLabel
            key={id}
            control={
              <Checkbox
                checked={id in @props.value}
                disabled={id in @props.excluded}
                onChange={@changeEventHandler(id)}
                value={id}
              />
            }
            label={info.name}
          />
      )}
    </FormGroup>

class MultipleCardChooser extends Component
  constructor: (props) ->
    super(props)
    @state =
      currentTab: 0

  handleChangeTab: (event, currentTab) =>
    @setState({ currentTab });

  render: ->
    { value, cards, types, excluded } = @props
    tabIds = (id for id of types)
    tabIndex = if @state.currentTab >= 0 and @state.currentTab < tabIds.length then @state.currentTab else 0
    tabId = tabIds[tabIndex]
    <div>
      <AppBar position="static">
        <Tabs value={tabIndex} onChange={@handleChangeTab}>
          {(<Tab key={id} label={types[id].title} /> for id in tabIds)}
        </Tabs>
      </AppBar>
      <CardChoices value={value} cards={cards} excluded={excluded} type={tabId} onChange={@props.onChange} />
      <h4>Selected Cards:</h4>
      <CardList selectedIds={value} cards={cards} types={types} />
    </div>

export default MultipleCardChooser
