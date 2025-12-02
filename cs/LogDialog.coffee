`
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import React, { Component } from 'react';
`

cardPhrase = (card, configuration, usePreposition = true) ->
  type = configuration.types[card.type]
  phrase = ""
  phrase += type.preposition if usePreposition
  phrase += type.article
  phrase += card.name
  return phrase

transcribedList = (list) ->
  string = list[0]
  if list.length > 1
    if list.length > 2
      for i in list[1...-1]
        string += ", " + i
      string += ", and " + list[list.length-1]
    else
      string += " and " + list[1]
  return string

playerList = (playerIds) -> if playerIds.length > 0 then transcribedList(playerIds) else "Nobody"

cardList = (cardIds, configuration) ->
  cards = configuration.cards
  names = (cardPhrase(cards[id], configuration, false) for id in cardIds)
  return transcribedList(names)

suggestedCardsClause = (cardIds, configuration) ->
  cards = configuration.cards
  suggestionOrder = configuration.suggestionOrder
  card1 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[0])[0]
  card2 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[1])[0]
  card3 = (cards[id] for id in cardIds when cards[id].type is suggestionOrder[2])[0]
  clause = cardPhrase(card1, configuration) + " "
  clause += cardPhrase(card2, configuration) + " " 
  clause += cardPhrase(card3, configuration)
  return clause

class LogDialog extends Component
  constructor: (props) ->
    super props
    @configuration = null
    return

  describeSetup: (info) -> "Playing #{@configuration.name} with #{playerList(info.players)}."

  describeHand: (info) -> "#{info.player} has #{cardList(info.cards, @configuration)}."

  describeSuggest: (info) ->
    if @configuration.rules is "master"
      @describeSuggestMaster info
    else
      @describeSuggestClassic info

  describeSuggestMaster: (info) ->
    "#{info.suggester} suggested: #{suggestedCardsClause(info.cards, @configuration)}.
     #{playerList(info.showed)} showed a card."

  describeSuggestClassic: (info) ->
    description = "#{info.suggester} suggested #{suggestedCardsClause(info.cards, @configuration)}."
    if info.showed.length > 0
      if info.showed.length > 1
        description += " #{playerList(info.showed[0...-1])} did not show a card."
      description += " #{info.showed[info.showed.length-1]} showed a card."
    else
      description += " Nobody showed a card."
    return description

  describeShow: (info) ->
    cards = @configuration.cards
    return "#{info.player} showed #{cardPhrase(cards[info.card], @configuration, false)}."

  describeAccuse: (info) ->
    "#{info.accuser} made an accusation: #{suggestedCardsClause(info.cards, @configuration)}.
     The accusation was #{if info.correct then "" else "not "}correct."

   describeCommlink: (info) ->
    "#{info.caller} asked #{info.receiver} about #{suggestedCardsClause(info.cards, @configuration)}.
     #{info.subject} #{if info.showed then "showed" else "did not show"} a card."

  describeEntry: (entry) ->
    if entry.setup?
      @describeSetup entry.setup
    else if entry.hand?
      @describeHand entry.hand
    else if entry.suggest?
      @describeSuggest entry.suggest
    else if entry.show?
      @describeShow entry.show
    else if entry.accuse?
      @describeAccuse entry.accuse
    else if entry.commlink?
      @describeCommlink entry.commlink
    else
      alert "Unknown log entry"

  render: ->
    { open, log, configurations, onClose } = @props
    @configuration = if log[0]? and log[0].setup? then configurations[log[0].setup.variation] else null

    handleDialogClose = (event, reason) ->
      return if reason is 'backdropClick'
      onClose()

    <Dialog open={open} fullScreen={true} onClose={handleDialogClose}>
      <DialogTitle id="form-dialog-title">Log</DialogTitle>
      <DialogContent>
        <ol>
          {<li key={step}> {@describeEntry(entry)} </li> for entry, step in log}
        </ol>
     </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={onClose}> Done </Button>
      </DialogActions>
    </Dialog>

export default LogDialog
