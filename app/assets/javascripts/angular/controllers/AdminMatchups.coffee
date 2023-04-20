angular.module('AdminMatchups', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'FilteredMatchups', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/filtered_matchups', 'matchups')

	.controller 'AdminMatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', 'NflTeam', 'PoolEntry', 'currentUser', '$modal', 'WebState', 'Week', 'SeasonWeeks', 'PickResults', 'FilteredMatchups', ($scope, $location, $http, $routeParams, Matchup, NflTeam, PoolEntry, currentUser, $modal, WebState, Week, SeasonWeeks, PickResults, FilteredMatchups) ->
		console.log("AdminMatchupsCtrl")

		# Getting the current system status

		$scope.current_week = {}
		$scope.season_weeks = {}
		$scope.picks = []
		$scope.matchups_with_picks = []
		$scope.matchups_without_picks = []

		week_id = $routeParams.week_id
		$scope.week_id = week_id
		console.log("Passed Week ID:" + $scope.week_id)
		$scope.matchups = []
		$scope.pool_entries = []

		$scope.getWebState = () ->
			console.log("...Looking up the WebState")
			$scope.web_state = WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.current_week = web_state.current_week
				$scope.open_for_picks = web_state.current_week.open_for_picks
				$scope.current_path = $location.path()
				$scope.loadAdminData()
			)

		$scope.getWebState()

		$scope.loadAdminData = () ->
			console.log("In AdminMatchupsCtrl.loadAdminData")

			scoring_path = /weeks\/\d*\/matchups\/scoring/
			admin_path = /weeks\/\d*\/matchups\/admin/
			new_path = /weeks\/\d*\/matchups\/new/
			edit_path = /weeks\/\d*\/matchups\/\d*/

			if scoring_path.test($scope.current_path)
				console.log("AdminMatchupsCtrl.loadAdminData scoring_path")
				$scope.loadFilteredMatchups()
			else if admin_path.test($scope.current_path)
				console.log("AdminMatchupsCtrl.loadAdminData admin_path")
				$scope.loadAllMatchups()
			else if new_path.test($scope.current_path)
				console.log("AdminMatchupsCtrl.loadAdminData new_path")
				$scope.loadNflTeams()
			else if edit_path.test($scope.current_path)
				console.log("AdminMatchupsCtrl.loadAdminData edit_path")
				$scope.matchup_id = $routeParams.matchup_id
				$scope.loadNflTeams().then(() ->
					$scope.loadEditingMatchup()
				)
			else
				console.log("no paths were matched in AdminMatchupsCtrl.loadAdminData")

		# $scope.loadPoolEntries = () ->
		# 	PoolEntry.query().then((pool_entries) ->
		# 		$scope.pool_entries = pool_entries
		# 		$scope.loadPicks()
		# 		$scope.loadNflTeams()
		# 		$scope.load_season_weeks()
		# 		$scope.loadAllMatchups()
		# 		console.log("*** Have pool entries, picks, teams, and season-weeks ***")
		# 	)

		$scope.loadEditingMatchup = () ->
			console.log("AdminMatchupsCtrl.loadEditingMatchup")
			Matchup.get($scope.matchup_id, $scope.week_id).then((returned_matchup) ->
				$scope.matchup.selected_home_team = returned_matchup.home_team
				$scope.matchup.selected_away_team = returned_matchup.away_team
				$scope.matchup.game_time = returned_matchup.game_time
			)

		# $scope.load_season_weeks = () ->
		# 	console.log("(load_season_weeks)")
		# 	SeasonWeeks.nested_query($scope.web_state.current_week.season.id).then((season_weeks) ->
		# 		console.log("(load_season_weeks) *** Have All Season Weeks ***")
		# 		$scope.season_weeks = season_weeks
		# 	)

		$scope.loadNflTeams = () ->
			NflTeam.query().then((nfl_teams) ->
				$scope.nfl_teams = nfl_teams
				console.log("*** Have nfl_teams***")
			)

		# $scope.loadPicks = () ->
		# 	console.log("in loadPicks()")
		# 	PickResults.nested_query($scope.week_id).then(
		# 		(picks) ->
		# 			$scope.picks = picks
		# 			$scope.associatePicks()
		# 			$scope.loadFilteredMatchups()
		# 			console.log("Have picks")
		# 		(json_error_data) ->
		# 			$scope.error_message = json_error_data.data[0].error
		# 			$scope.loadFilteredMatchups()
		# 	)

		# $scope.associatePicks = ->
		# 	for pool_entry in $scope.pool_entries
		# 		for pick in $scope.picks
		# 			if pick.pool_entry_id == pool_entry.id
		# 				angular.extend(pool_entry, pick)
		# 				console.log("A pick was associated with a pool entry")

		$scope.loadFilteredMatchups = () ->
			FilteredMatchups.nested_query($scope.week_id).then((matchups) ->
				$scope.filtered_matchups = matchups
				console.log("*** Have FILTERED matchups for week:"+$scope.week_id + " ***")
			)

		$scope.loadAllMatchups = () ->
			Matchup.nested_query($scope.week_id).then((matchups) ->
				$scope.all_matchups = matchups
				console.log("*** Have ALL matchups for week:"+$scope.week_id + " ***")
			)

		# Saving the creation or editing of a new Matchup

		$scope.save = (matchup) ->
			console.log("AdminMatchupsCtrl.save...")
			week_id = matchup.week_id
			if matchup.id?
				console.log("Saving matchup id " + matchup.id)
				matchup.home_team_id = $scope.matchup.selected_home_team.id
				matchup.away_team_id = $scope.matchup.selected_away_team.id
				matchup.game_time = $scope.matchup.selected_game_time
				Matchup.save(matchup, $scope.week_id).then((matchup) ->
					$scope.matchup = matchup
				)
			else
				console.log("First-time save need POST new id")
				matchup.home_team_id = $scope.matchup.selected_home_team.id
				matchup.away_team_id = $scope.matchup.selected_away_team.id
				matchup.game_time = $scope.matchup.selected_game_time
				Matchup.create(matchup, $scope.week_id).then((matchup) ->
					$scope.matchup = matchup
				)
			$location.path ('/weeks/' + $scope.week_id + '/matchups/admin')

		# Below was used for a while, but problematic with losing certain matchups

		# $scope.isPicked = (matchup) ->
		# 	console.log("in isPicked")
		# 	for pick in $scope.picks
		# 		console.log("in scope.picks")
		# 		if pick.team_id == matchup.home_team_id
		# 			console.log("home team matches up for " + pick.nfl_team.name)
		# 			return true
		# 		else if pick.team_id == matchup.away_team_id
		# 			console.log("away team matches up for " + pick.nfl_team.name)
		# 			return true
		# 		else
		# 			console.log("no match for " + pick.nfl_team.name)
		# 			return false

		$scope.notPicked = (matchup) ->
			console.log("in notPicked")
			if $scope.picks == []
				true
			else
				for pick in $scope.picks
					if pick.team_id == (matchup.home_team_id or matchup.away_team_id)
						false 
					else 
						true

		# $scope.filterMatchups = () ->
		# 	console.log("in filterMatchups()")
		# 	for matchup in $scope.matchups
		# 		for pick in $scope.picks
		# 			if pick.team_id == (matchup.home_team_id or matchup.away_team_id)
		# 				$scope.matchups_with_picks.push matchup
		# 			else
		# 				$scope.matchups_without_picks.push matchup
		# 	console.log("end of filterMatchups")

		# Outcome Selections for Administrators

		$scope.selectTie = (matchup) ->
			console.log("Saving matchup outcome as a Tie Game")
			matchup.tie = true
			matchup.winning_team_id = null
			Matchup.save(matchup, matchup.week_id).then((matchup) ->
				$scope.matchup = matchup
				$scope.tieSelected = true
			)

		$scope.selectHomeTeamWin = (matchup) ->
			console.log("Saving matchup outcome as Home Team Wins")
			matchup.tie = false
			matchup.winning_team_id = matchup.home_team_id
			Matchup.save(matchup, matchup.week_id).then((matchup) ->
				$scope.matchup = matchup
				$scope.homeSelected = true
			)

		$scope.selectAwayTeamWin = (matchup) ->
			console.log("Saving matchup outcome as Away Team Wins")
			matchup.tie = false
			matchup.winning_team_id = matchup.away_team_id
			Matchup.save(matchup, matchup.week_id).then((matchup) ->
				$scope.matchup = matchup
			)

		$scope.cancelOutcomeSelection = (matchup) ->
			console.log("Cancelling outcome selection for matchup")
			matchup.tie = null
			matchup.winning_team_id = null
			Matchup.save(matchup, matchup.week_id)

		$scope.saveOutcome = (matchup) ->
			console.log("Saving outcome for matchup"+matchup)
			week_id = matchup.week_id
			Matchup.post("save_outcome", matchup, week_id).then(()->
				$scope.loadFilteredMatchups()
			)

		$scope.revertOutcome = (matchup) ->
			console.log("Reverting outcome for matchup"+matchup)
			week_id = matchup.week_id
			Matchup.post("revert_outcome", matchup, week_id).then(()->
				$scope.loadFilteredMatchups()
			)

		$scope.matchupCompleted = (matchup) ->
			if matchup.completed == true then true

		$scope.displayOutcomeSaveButtons = (matchup) ->
			if matchup.tie? then true

		$scope.displayMatchupEditButtons = (matchup) ->
			if matchup.tie == null then true

		$scope.tie_button_class = (matchup) ->
			if matchup.tie == true
				matchup.winning_team_text = "Tie Game"
				"btn btn-warning"
			else
				"btn btn-default"

		$scope.home_button_class = (matchup) ->
			if matchup.winning_team_id == matchup.home_team_id
				matchup.winning_team_text = matchup.home_team.name + " as the Winner"
				"btn btn-primary"
			else
				"btn btn-default"

		$scope.away_button_class = (matchup) ->
			if matchup.winning_team_id != matchup.home_team_id && matchup.tie == false
				matchup.winning_team_text = matchup.away_team.name + " as the Winner"
				"btn btn-success"
			else
				"btn btn-default"

		$scope.winningTeam = (matchup) ->
			if matchup.winning_team_id == matchup.home_team_id
				matchup.home_team.name
			else if matchup.winning_team_id == matchup.away_team_id
				matchup.away_team.name
			else
				"It was a tie!"

		$scope.deleteMatchup = (matchup) ->
			console.log("MatchupCtrl.delete...")
			week_id = matchup.week_id
			# Add checking for if there are picks associated with this Matchup
			if matchup.id?
				console.log("Deleting matchup id " + matchup.id)
				Matchup.remove(matchup, week_id).then((matchup) ->
					Matchup.nested_query($scope.week_id).then((matchups) ->
						$scope.matchups = matchups
					)
				)

		# Modal

		$scope.open = (size, matchup) ->
			modalInstance = $modal.open(
				templateUrl: "confirmOutcomeModal.html"
				controller: ModalInstanceCtrl
				size: size
				resolve:
					matchup: ->
						matchup
			)
			modalInstance.result.then ((matchup) ->
				console.log("first function of modalInstance result")
				$scope.saveOutcome(matchup)
			), ->
				console.log("Modal dismissed at: " + new Date())

		ModalInstanceCtrl = ($scope, $modalInstance, matchup) ->
			console.log("In ModalInstanceCtrl")
			console.log("this is what is in matchup" + matchup.id)

			$scope.matchup = matchup

			$scope.ok = ->
				$modalInstance.close(matchup)

			$scope.cancel = ->
				$modalInstance.dismiss("cancel")

		$scope.openRevertDialogue = (size, matchup) ->
			modalInstance = $modal.open(
				templateUrl: "revertOutcomeModal.html"
				controller: ModalInstanceCtrl
				size: size
				resolve:
					matchup: ->
						matchup
			)
			modalInstance.result.then ((matchup) ->
				console.log("first function of modalInstance result")
				$scope.revertOutcome(matchup)
			), ->
				console.log("Modal dismissed at: " + new Date())

		ModalInstanceCtrl = ($scope, $modalInstance, matchup) ->
			console.log("In ModalInstanceCtrl")
			console.log("this is what is in matchup" + matchup.id)

			$scope.matchup = matchup

			$scope.ok = ->
				$modalInstance.close(matchup)

			$scope.cancel = ->
				$modalInstance.dismiss("cancel")
	]