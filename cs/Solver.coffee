class Card
  constructor: (@holders, @info) ->

  remove: (playerId) ->
    @holders = @holders.filter((h) -> h isnt playerId)
    return

  mightBeHeldBy: (playerId) -> playerId in @holders

  isHeldBy: (playerId) -> @holders.length == 1 and @holders[0] is playerId

  holderIsKnown: () -> @holders.length == 1

class Player
  constructor: (@potential) ->

  remove: (cardId) ->
    @potential = @potential.filter((c) -> c isnt cardId)
    return

  doesNotHold: (cardId) -> cardId not in @potential

  mightHold: (cardId) -> cardId in @potential

class Solver
  constructor: (configuration, playerIds) ->
    @ANSWER_PLAYER_ID = "ANSWER" # The answer is treated as a player
    @rulesId          = configuration.rulesId
    @types            = configuration.types
    @cards            = {}
    @players          = {}
    @discoveriesLog   = []
    @suggestions      = []
    @accusations      = []
    @commlinks        = []
    @facts            = []

    cardIds = Object.keys(configuration.cards)

    playerIdsIncludingAnswer = playerIds.concat(@ANSWER_PLAYER_ID)

    @cards[id] = new Card(playerIdsIncludingAnswer, info) for id, info of configuration.cards
    @players[p] = new Player(cardIds) for p in playerIdsIncludingAnswer
    @ANSWER = @players[@ANSWER_PLAYER_ID]

  accuse: (accuserId, cardIds, correct, id) ->
    @discoveriesLog = []

    accusation = { id, accuserId, cardIds, correct }
    @accusations.push accusation

    changed = false
    changed = @deduceFromAccusation(accusation, changed)
    changed = @makeOtherDeductions(changed)
    return changed

  hand: (playerId, cardsIds) ->
    @discoveriesLog = []

    changed = false
    changed = @deduceFromHand(playerId, cardsIds, changed)
    changed = @makeOtherDeductions(changed)
    return changed

  show: (playerId, cardId) ->
    @discoveriesLog = []

    changed = false
    changed = @deduceFromShow(playerId, cardId, changed)
    changed = @makeOtherDeductions(changed)
    return changed

  suggest: (suggesterId, cardIds, showedIds, id) ->
    @discoveriesLog = []

    suggestion = { id, suggesterId, cardIds, showedIds }
    @suggestions.push suggestion

    changed = false
    changed = @deduceFromSuggestion(suggestion, changed)
    changed = @makeOtherDeductions(changed)
    return changed

  commlink: (callerId, receiverId, cardIds, showed, id) ->
    @discoveriesLog = []

    comm = { id, callerId, receiverId, cardIds, showed }
    @commlinks.push comm

    changed = false
    changed = @deduceFromCommlink(comm, changed)
    changed = @makeOtherDeductions(changed)
    return changed

  # If the player must hold one of the cards, but we know it doesn't hold all but one, then that one must be the one that is held
  playerMustHoldOne: (playerId, cardIds) ->
    player = @players[playerId]
    count = 0
    held = null
    for id in cardIds
      if player.mightHold(id)
        ++count
        return null if count > 1 # Early out -- might hold more than one, so not all-but-one
        held = id
    return held

  # If the player must not hold one of the cards, but we know it holds all but one, then that one is the one it doesn't hold
  playerMustNotHoldOne: (playerId, cardIds) ->
    count = 0
    notHeld = null
    for id in cardIds
      if not @cards[id].isHeldBy(playerId)
        ++count
        return null if count > 1 # Early out -- more than one card is not held, so not all-but-one
        notHeld = id
    return notHeld

  cardsThatMightBeHeldBy: (playerId) -> @players[playerId].potential

  whoMightHold: (cardId) -> @cards[cardId].holders

  playersAreValid: (playerIds) ->
    for id in playerIds
      return false if not @playerIsValid(id)
    return true

  playerIsValid: (playerId) -> playerId isnt @ANSWER_PLAYER_ID and playerId of @players

  cardsAreValid: (cardIds) ->
    for id in cardIds
      return false if not @cardIsValid(id)
    return true

  cardIsValid: (cardId) -> cardId of @cards

  typeIsValid: (typeId) -> typeId in @types

  deduceFromAccusation: (accusation, changed) ->
    { id, accuserId, cardIds, correct } = accusation

    # You can deduce from an accusation that:
    #    The accuser does not have the cards in the accusation.
    #    If the accusation is correct, then those are the cards.
    #    If the accusation is incorrect, then
    #      If two of the cards are held by the answer, then it must not hold the third

    @addDiscoveries accuserId, cardIds, false, "stated these cards in accusation #" + id
    changed = @disassociatePlayerWithCards(accuserId, cardIds, changed)

    if correct
      for cardId in cardIds
        changed = @associatePlayerWithCard(@ANSWER_PLAYER_ID, cardId, changed)
    else
      mustNotHoldId = @playerMustNotHoldOne(@ANSWER_PLAYER_ID, cardIds)
      if mustNotHoldId isnt null
        @addDiscovery @ANSWER_PLAYER_ID, mustNotHoldId, false, "accusation #" + id + " was wrong but the answer does hold the others"
        changed = @disassociatePlayerWithCard(@ANSWER_PLAYER_ID, mustNotHoldId, changed)
    return changed

  # Make deductions based on the player having exactly these cards
  deduceFromHand: (playerId, hand, changed) ->
    # Associate the player with every card in the hand and disassociate the player with every other card.
    for cardId of @cards
      if cardId in hand
        @addDiscovery playerId, cardId, true, "hand"
        changed = @associatePlayerWithCard(playerId, cardId, changed)
      else
        @addDiscovery playerId, cardId, false, "hand"
        changed = @disassociatePlayerWithCard(playerId, cardId, changed)
    return changed
 
  # Make deductions based on the player having this cardId
  deduceFromShow: (playerId, cardId, changed) ->
    @addDiscovery playerId, cardId, true, "revealed"
    changed = @associatePlayerWithCard(playerId, cardId, changed)
    return changed

  deduceFromSuggestion: (suggestion, changed) ->
    if @rulesId == "master"
      changed = @deduceFromSuggestionWithMasterRules(suggestion, changed)
    else
      changed = @deduceFromSuggestionWithClassicRules(suggestion, changed)
    return changed

  deduceFromSuggestionWithClassicRules: (suggestion, changed) ->
    { id, suggesterId, cardIds, showedIds } = suggestion

    # You can deduce from a suggestion that:
    #    If nobody showed a card, then none of the players (except possibly the suggester or the answer) have the cards.
    #    Only the last player in the showed list might hold any of the suggested cards.
    #    If the player that showed a card does not hold two of the cards, then the player must hold the third.

    if showedIds is null or showedIds.length == 0
      for playerId of @players
        if playerId isnt @ANSWER_PLAYER_ID and playerId isnt suggesterId
          @addDiscoveries playerId, cardIds, false, "did not show a card in suggestion #" + id
          changed = @disassociatePlayerWithCards(playerId, cardIds, changed)
    else
      # All but the last player have none of the cards
      for i in [0...showedIds.length-1]
        playerId = showedIds[i]
        @addDiscoveries playerId, cardIds, false, "did not show a card in suggestion #" + id
        changed = @disassociatePlayerWithCards(playerId, cardIds, changed)

      # The last player showed a card.
      # If the player does not hold all but one of cards, the player must hold the one.
      playerId = showedIds[showedIds.length - 1]
      mustHoldId = @playerMustHoldOne(playerId, cardIds)
      if mustHoldId isnt null
        @addDiscovery playerId, mustHoldId, true, "showed a card in suggestion #" + id + ", and does not hold the others"
        changed = @associatePlayerWithCard(playerId, mustHoldId, changed)
    return changed

  deduceFromSuggestionWithMasterRules: (suggestion, changed) ->
    { id, suggesterId, cardIds, showedIds } = suggestion

    # You can deduce from a suggestion that:
    #    If a player shows a card but does not have all but one of the suggested cards, the player must hold the one.
    #    If a player (other than the answer and suggester) does not show a card, the player has none of the suggested cards.
    #    If all suggested cards are shown, then the answer and the suggester hold none of the suggested cards.

    for playerId of @players

      # If the player showed a card ...
      if playerId in showedIds
        # ..., then if the player does not hold all but one of the cards, the player must hold the one.
        mustHoldId = @playerMustHoldOne(playerId, cardIds)
        if mustHoldId isnt null
          @addDiscovery playerId, mustHoldId, true, "showed a card in suggestion #" + id + ", and does not hold the others"
          changed = @associatePlayerWithCard(playerId, mustHoldId, changed)

      # Otherwise, if the player is other than the answer and suggester ...
      else if playerId isnt @ANSWER_PLAYER_ID and playerId isnt suggesterId
        # ... then they don't hold any of them.
        @addDiscoveries playerId, cardIds, false, "did not show a card in suggestion #" + id
        @disassociatePlayerWithCards(playerId, suggestion.cardIds, changed)

      # Otherwise, for the answer and suggester, if 3 cards were shown ...
      else
        if showedIds.length == 3
          # ... then they don't hold them.
          @addDiscoveries playerId, cardIds, false, "all three cards were shown by other players in suggestion #" + id
          changed = @disassociatePlayerWithCards(playerId, cardIds, changed)
    return changed

  deduceFromCommlink: (comm, changed) ->
    { id, receiverId, cardIds, showed } = comm

    # You can deduce from an commlink that:
    #  If the the receiver showed a card, then if they don't have two of them, then they must have the third
    #  Otherwise, the receiver has none of the cards

    if showed
      # If the player does not hold all but one of cards, the player must hold the one.
      mustHoldId = @playerMustHoldOne(receiverId, cardIds)
      if mustHoldId isnt null
        @addDiscovery receiverId, mustHoldId, true, "showed a card in commlink #" + id + ", and does not hold the others"
        changed = @associatePlayerWithCard(receiverId, mustHoldId, changed)
    else
      # The receiver has none of the cards
      @addDiscoveries receiverId, cardIds, false, "did not show a card in commlink #" + id
      changed = @disassociatePlayerWithCards(receiverId, cardIds, changed)
    return changed



  makeOtherDeductions: (changed) ->
    @addCardHoldersToDiscoveries()
    changed = @checkThatAnswerHoldsExactlyOneOfEach(changed)

    # While something has changed, then keep re-applying all the suggestions and accusations
    while (changed)
      changed = false
      changed = @deduceFromSuggestion(suggestion, changed) for suggestion in @suggestions
      changed = @deduceFromAccusation(accusation, changed) for accusation in @accusations
      changed = @deduceFromCommlink(commlink, changed) for commlink in @commlinks
      @addCardHoldersToDiscoveries()
      changed = @checkThatAnswerHoldsExactlyOneOfEach(changed)

    @addCardHoldersToDiscoveries()
    return changed

  checkThatAnswerHoldsExactlyOneOfEach: (changed) ->
    answer = @players[@ANSWER_PLAYER_ID]

    # Find the cards that are known to be held by the answer
    heldByAnswer = {}
    for cardId in answer.potential
      card = @cards[cardId]
      heldByAnswer[card.info.type] = cardId if card.isHeldBy(@ANSWER_PLAYER_ID)

    # If so, then the answer can not hold any other cards of the same types
    potential = @ANSWER.potential[..]  # Must use a copy because the list of cards may be changed on the fly
    for cardId in potential
      card = @cards[cardId]
      for heldType, heldId of heldByAnswer
        if card.info.type is heldType and cardId isnt heldId
          @addDiscovery @ANSWER_PLAYER_ID, cardId, false, "ANSWER can only hold one " + heldType
          changed = @disassociatePlayerWithCard(@ANSWER_PLAYER_ID, cardId, changed)

    # For each type, if there is only one card that might be held by the answer, then it must be held by the answer
    onlyPossible = {}
    for cardId in @ANSWER.potential
      card = @cards[cardId]
      if not card.isHeldBy(@ANSWER_PLAYER_ID)
        typeId = card.info.type
        if onlyPossible[typeId]?
          onlyPossible[typeId].only = false
        else 
          onlyPossible[typeId] = { cardId: cardId, only: true }

    for typeId, info of onlyPossible
      if info.only
          @addDiscovery @ANSWER_PLAYER_ID, info.cardId, true, "Only " + typeId + " that ANSWER can hold"
          changed = @associatePlayerWithCard(@ANSWER_PLAYER_ID, info.cardId, changed)

    return changed

  associatePlayerWithCard: (playerId, cardId, changed) ->
    # Simply remove all others as potential holders unless already associated with a player
    changed = @disassociateOtherPlayersWithCard(playerId, cardId, changed) if not  @cards[cardId].holderIsKnown()
    return changed 

  disassociatePlayerWithCard: (playerId, cardId, changed) ->
    player = @players[playerId]
    if player.mightHold(cardId)
      player.remove(cardId)
      @cards[cardId].remove(playerId)
      changed = true
      @addDiscovery playerId, cardId, false # Add this discovery, but don't log it 
    return changed

  disassociatePlayerWithCards: (playerId, cardIds, changed) ->
    changed = @disassociatePlayerWithCard(playerId, id, changed) for id in cardIds
    return changed

  disassociateOtherPlayersWithCard: (playerId, cardId, changed) ->
    changed = @disassociatePlayerWithCard(otherId, cardId, changed) for otherId of @players when otherId isnt playerId
    return changed

  cardIsType: (cardId, type) ->  @cards[cardId].info.type is type

  addDiscovery: (playerId, cardId, holds, reason) ->
    # Check if the fact is not already known
    for f in @facts
      return if f.playerId is playerId and f.cardId is cardId

    fact = { playerId, cardId, holds }
    @facts.push fact

    if reason?
      cardInfo = @cards[cardId].info
      typeinfo = @types[cardInfo.type]
      discovery = playerId +
        (if holds then " holds " else " does not hold ") +
        typeinfo.article + 
        cardInfo.name +
        ": " +
        reason
      @discoveriesLog.push discovery

  addDiscoveries: (playerId, cardIds, holds, reason = null) ->
    @addDiscovery(playerId, c, holds, reason) for c in cardIds
    return

  addCardHoldersToDiscoveries: ->
    for cardId, card of @cards
      @addDiscovery(card.holders[0], cardId, true, "nobody else holds it") if card.holderIsKnown()

export default Solver
