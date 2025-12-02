`
import AppBar from '@mui/material/AppBar';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormControl from '@mui/material/FormControl';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import React, { Component } from 'react';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
`

CardChoices = (props) ->
  { value, type, cards, onChange } = props
  <RadioGroup row name="cards" value={value} onChange={onChange}>
    {
      for id, info of cards when info.type is type
        <FormControlLabel
          key={id}
          value={id}
          control={<Radio />} 
          label={info.name}
        />
    }
  </RadioGroup>

class CardChooser extends Component
  constructor: (props) ->
    super props
    @state =
      currentTab: 0
    return

  handleChangeTab: (event, currentTab) =>
    @setState { currentTab }
    return

  render: ->
    { value, cards, types } = @props
    tabIds = Object.keys(types)
    tabIndex = if @state.currentTab >= 0 and @state.currentTab < tabIds.length then @state.currentTab else 0
    tabId = tabIds[tabIndex]
    <div>
      <AppBar position="static">
        <Tabs value={tabIndex} onChange={@handleChangeTab}>
          {<Tab key={id} label={types[id].title} /> for id in tabIds}
        </Tabs>
      </AppBar>
      <FormControl component="fieldset">
        <CardChoices
          value={value} 
          type={tabId} 
          cards={cards} 
          onChange={(event) => @props.onChange(event.target.value)} 
        />
      </FormControl>
    </div>

export default CardChooser
