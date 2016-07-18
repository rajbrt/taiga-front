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

class TagLineCommonController

    @.$inject = [
        "tgTagLineService"
    ]

    constructor: (@tagLineService) ->
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

    ## UNCOMMON UTILITIES

    onAddTag: (tag, color, project) ->
        console.log tag, color, project
        @.loadingAddTag = true
        value = trim(tag.toLowerCase())

        tags = @.project.tags
        projectTags = project.tags_colors

        tags = [] if not tags?
        projectTags = {} if not projectTags?

        if value not in tags
            tags.push(value)

        projectTags[tag] = color || null

        project.tags = tags
        @.addTag = false
        @.loadingAddTag = false
        #Update Model

    onRemoveTag: (tag) ->
        @.loadingRemoveTag = tag
        value = trim(tag.toLowerCase())

        tags = @.project.tags

        _.pull(tags, value)

        @.loadingRemoveTag = false
        #Update Model

module.controller("TagLineCommonCtrl", TagLineCommonController)
