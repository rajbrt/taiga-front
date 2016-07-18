###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File:tag-line-detail.controller.spec.coffee
###

describe "TagLineDetail", ->
    provide = null
    controller = null
    TagLineController = null
    mocks = {}

    _mockTgTagLineService = () ->
        mocks.tgTagLineService = {
            checkPermissions: sinon.stub()
            createColorsArray: sinon.stub()
            renderTags: sinon.stub()
        }

        provide.value "tgTagLineService", mocks.tgTagLineService

    _mockRootScope = () ->
        mocks.rootScope = {
            $broadcast: sinon.stub()
        }

        provide.value "rootScope", mocks.rootScope

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgQueueModelTransformation = () ->
        mocks.tgQueueModelTransformation = {
            save: sinon.stub()
        }

        provide.value "$tgQueueModelTransformation", mocks.tgQueueModelTransformation


    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgTagLineService()
            _mockRootScope()
            _mockTgConfirm()
            _mockTgQueueModelTransformation()

            return null

    beforeEach ->
        module "taigaCommon"

        _mocks()

        inject ($controller) ->
            controller = $controller

        TagLineController = controller "TagLineCtrl"
        TagLineController.tags = []
        TagLineController.colorArray = []
        TagLineController.addTag = false

    it "check permissions", () ->
        TagLineController.project = {}
        TagLineController.project.my_permissions = [
            'permission1',
            'permission2'
        ]
        TagLineController.permissions = 'permissions1'

        TagLineController.checkPermissions()
        expect(mocks.tgTagLineService.checkPermissions).have.been.calledWith(TagLineController.project.my_permissions, TagLineController.permissions)

    it "create Colors Array", () ->
        projectTagColors = 'string'
        mocks.tgTagLineService.createColorsArray.withArgs(projectTagColors).returns(true)
        TagLineController._createColorsArray(projectTagColors)
        expect(TagLineController.colorArray).to.be.equal(true)

    it "render tags", () ->
        tags = ['tag1', 'tag2']
        project = ['project1', 'project2']
        TagLineController._renderTags(tags, project)
        expect(mocks.tgTagLineService.renderTags).have.been.calledWith(tags, project)

    it "display tag input", () ->
        TagLineController.addTag = false
        TagLineController.displayTagInput()
        expect(TagLineController.addTag).to.be.true


    it "on close tag input", () ->
        TagLineController.addTag = true
        event = {
            keyCode: 27
        }
        TagLineController.closeTagInput(event)
        expect(TagLineController.addTag).to.be.false

    # it "on delete tag success", () ->
    #     tag = {
    #         name: "tag"
    #     }
    #     TagLineController.loadingRemoveTag = tag.name
    #     TagLineController.onDeleteTag(tag)
    #



    # onDeleteTag: (tag) ->
    #     @.loadingRemoveTag = tag.name
    #     onDeleteTagSuccess = () =>
    #         @rootScope.$broadcast("object:updated")
    #         @.loadingRemoveTag = false
    #
    #     onDeleteTagError = () =>
    #         @confirm.notify("error")
    #         @.loadingRemoveTag = false
    #
    #     tagName = trim(tag.name.toLowerCase())
    #     transform = @modelTransform.save (item) ->
    #         tags = _.clone(item.tags, false)
    #         item.tags = _.pull(tags, tagName)
    #         return item
    #
    #     return transform.then(onDeleteTagSuccess, onDeleteTagError)
