`
import Grid from '@mui/material/Grid';
import Icon from '@mui/material/Icon';
import React from 'react';
`

Yes = (props) ->
  <Icon>
    {if props.isAnswer then "star" else "check_box"}
  </Icon>

No = () -> ""

Maybe = () ->
  <Icon color="disabled">
    indeterminate_check_box
  </Icon>

StateElement = (props) ->
  { card, player } = props

  if card.isHeldBy player
    <Yes isAnswer={player is "ANSWER"} />
  else if card.mightBeHeldBy player
    <Maybe />
  else
    <No />

HeaderRow = (props) ->
  { players } = props

  <Grid container item xs={12} justifyContent="center">
    <Grid item xs={4}><b>Card</b></Grid>
    {<Grid item key={playerId} xs={1}><b>{playerId}</b></Grid> for playerId of players}
  </Grid>

StateRow = (props) ->
  {card, players} = props

  <Grid container item xs={12} justifyContent="center">
    <Grid item xs={4}>
      {
        if card.isHeldBy("ANSWER")
          <b> {card.info.name} </b>
        else
          card.info.name
      }
    </Grid>
    {
      for playerId of players
        <Grid 
          item 
          key={playerId} 
          xs={1}> 
          <StateElement card={card} player={playerId} /> 
        </Grid> 
    }
  </Grid>

CurrentState = (props) ->
  { cards, players } = props.solver

  <Grid container>
    <HeaderRow players={players} />
    {<StateRow key={id} card={card} players={players} /> for id, card of cards}
  </Grid>

export default CurrentState
