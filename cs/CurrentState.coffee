`
import React, { Component } from 'react';

import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid';
import Icon from '@material-ui/core/Icon';
`

StateElement = (props) ->
  {card, playerId} = props

  if card.isHeldBy playerId
    return <Icon>check_box</Icon>
  else if card.mightBeHeldBy playerId
    return <Icon>indeterminate_check_box</Icon>
  else
    return <Icon>check_box_outline_blank</Icon>

HeaderRow = (props) ->
  { players } = props

  <Grid container item xs={12} justify="center">
    <Grid item xs={4}><b>Card</b></Grid>
    {(<Grid item key={playerId} xs={1}><b>{playerId}</b></Grid> for playerId of players)}
  </Grid>

StateRow = (props) ->
  {card, players} = props

  <Grid container item xs={12} justify="center">
    <Grid item xs={4}>
      {card.info.name}
    </Grid>
    {(<Grid item key={playerId} xs={1}> <StateElement card={card} playerId={playerId} /> </Grid> for playerId of players)}
  </Grid>

StateGrid = (props) ->
  {cards, players} = props

  <Grid container>
    <HeaderRow players={players} />
    {(<StateRow key={id} card={card} players={players} /> for id, card of cards)}
  </Grid>

class CurrentState extends Component
  render: ->
    <div>
      <Button variant="contained" color="primary" onClick={@props.app.showHandDialog}>Hand</Button>
      <Button variant="contained" color="primary" onClick={@props.app.showSuggestDialog}>Suggest</Button>
      <Button variant="contained" color="primary" onClick={@props.app.showShowDialog}>Show</Button>
      <hr />
      <StateGrid cards={@props.solver.cards} players={@props.solver.players} />
    </div>

export default CurrentState
