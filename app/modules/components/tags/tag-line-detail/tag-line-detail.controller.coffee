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
# File: tag-line.controller.coffee
###

trim = @.taiga.trim

module = angular.module('taigaCommon')

class TagLineController

    @.$inject = [
        "$rootScope",
        "$tgConfirm",
        "$tgQueueModelTransformation",
        "tgTagLineService"
    ]

    constructor: (@rootScope, @confirm, @modelTransform, @tagLineService) ->
        @.tags = []
        @.colorArray = []
        @.addTag = false

    checkPermissions: () ->
        return @tagLineService.checkPermissions(@.project.my_permissions, @.permissions)

    _createColorsArray: (projectTagColors) ->
        @.colorArray =  @tagLineService.createColorsArray(projectTagColors)

    _renderTags: (tags, project) ->
        return @tagLineService.renderTags(tags, project)

    displayTagInput: () ->
        @.addTag = true

    closeTagInput: (event) ->
        if event.keyCode == 27
            @.addTag = false

    onDeleteTag: (tag) ->
        @.loadingRemoveTag = tag.name
        onDeleteTagSuccess = () =>
            @rootScope.$broadcast("object:updated")
            @.loadingRemoveTag = false

        onDeleteTagError = () =>
            @confirm.notify("error")
            @.loadingRemoveTag = false

        tagName = trim(tag.name.toLowerCase())
        transform = @modelTransform.save (item) ->
            tags = _.clone(item.tags, false)
            item.tags = _.pull(tags, tagName)
            return item

        return transform.then(onDeleteTagSuccess, onDeleteTagError)

    onAddTag: (tag, color, project) ->
        @.loadingAddTag = true
        if !color
            color = null

        newTag = [tag, color]

        onAddTagSuccess = (project) =>
            project.tags_colors[tag] = color
            @rootScope.$broadcast("object:updated") #its a kind of magic.
            @.addTag = false
            @.loadingAddTag = false

        onAddTagError = () =>
            @.loadAddTag = false
            @confirm.notify("error")

        transform = @modelTransform.save (item) ->
            if not item.tags
                item.tags = []

            if not item.tags
                project.tags_colors = {}

            tags = _.clone(item.tags)
            tags.push(newTag) if tag.name not in tags
            item.tags = tags
            return item

        return transform.then(onAddTagSuccess(project), onAddTagError)

module.controller("TagLineCtrl", TagLineController)
