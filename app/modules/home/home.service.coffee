###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: home.service.coffee
###

groupBy = @.taiga.groupBy

class HomeService extends taiga.Service
    @.$inject = [
        "$tgNavUrls",
        "tgResources",
        "tgProjectsService"
    ]

    constructor: (@navurls, @rs, @projectsService) ->

    _attachProjectInfoToWorkInProgress: (workInProgress, projectsById) ->
        _attachProjectInfoToDuty = (duty, objType) =>
            project = projectsById.get(String(duty.get('project')))

            ctx = {
                project: project.get('slug')
                ref: duty.get('ref')
            }

            url = @navurls.resolve("project-#{objType}-detail", ctx)

            duty = duty.set('url', url)
            duty = duty.set('project', project)
            duty = duty.set("_name", objType)

            return duty

        _getValidDutiesAndAttachProjectInfo = (duties, dutyType)->
            # Exclude duties where I'm not member of the project
            duties = duties.filter((duty) ->
                return projectsById.get(String(duty.get('project'))))

            duties = duties.map (duty) ->
                return _attachProjectInfoToDuty(duty, dutyType)

            return duties

        assignedTo = workInProgress.get("assignedTo")

        if assignedTo.get("userStories")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("userStories"), "userstories")
            assignedTo = assignedTo.set("userStories", _duties)

        if assignedTo.get("tasks")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("tasks"), "tasks")
            assignedTo = assignedTo.set("tasks", _duties)


        if assignedTo.get("issues")
            _duties = _getValidDutiesAndAttachProjectInfo(assignedTo.get("issues"), "issues")
            assignedTo = assignedTo.set("issues", _duties)


        watching = workInProgress.get("watching")

        if watching.get("userStories")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("userStories"), "userstories")
            watching = watching.set("userStories", _duties)

        if watching.get("tasks")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("tasks"), "tasks")
            watching = watching.set("tasks", _duties)

        if watching.get("issues")
            _duties = _getValidDutiesAndAttachProjectInfo(watching.get("issues"), "issues")
            watching = watching.set("issues", _duties)

        workInProgress = workInProgress.set("assignedTo", assignedTo)
        workInProgress = workInProgress.set("watching", watching)

    getWorkInProgress: (userId) ->
        projectsById = Immutable.Map()

        projectsPromise = @projectsService.getProjectsByUserId(userId).then (projects) ->
            projectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

        assignedTo = Immutable.Map()

        params = {
            status__is_closed: false
            assigned_to: userId
        }

        params_us = {
            is_closed: false
            assigned_to: userId
        }

        assignedUserStoriesPromise = @rs.userstories.listInAllProjects(params_us).then (userstories) ->
            assignedTo = assignedTo.set("userStories", userstories)

        assignedTasksPromise = @rs.tasks.listInAllProjects(params).then (tasks) ->
            assignedTo = assignedTo.set("tasks", tasks)

        assignedIssuesPromise = @rs.issues.listInAllProjects(params).then (issues) ->
            assignedTo = assignedTo.set("issues", issues)

        params = {
            status__is_closed: false
            watchers: userId
        }

        params_us = {
            is_closed: false
            watchers: userId
        }

        watching = Immutable.Map()

        watchingUserStoriesPromise = @rs.userstories.listInAllProjects(params_us).then (userstories) ->
            watching = watching.set("userStories", userstories)

        watchingTasksPromise = @rs.tasks.listInAllProjects(params).then (tasks) ->
            watching = watching.set("tasks", tasks)

        watchingIssuesPromise = @rs.issues.listInAllProjects(params).then (issues) ->
            watching = watching.set("issues", issues)

        workInProgress = Immutable.Map()

        Promise.all([
            projectsPromise
            assignedUserStoriesPromise,
            assignedTasksPromise,
            assignedIssuesPromise,
            watchingUserStoriesPromise,
            watchingTasksPromise,
            watchingIssuesPromise
        ]).then =>
            workInProgress = workInProgress.set("assignedTo", assignedTo)
            workInProgress = workInProgress.set("watching", watching)

            workInProgress = @._attachProjectInfoToWorkInProgress(workInProgress, projectsById)

            return workInProgress

angular.module("taigaHome").service("tgHomeService", HomeService)
