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
# File:tag-line-common.controller.spec.coffee
###

describe "TagLineCommon", ->
    provide = null
    controller = null
    TagLineCommonCtrl = null
    mocks = {}

    _mockTgTagLineService = () ->
        mocks.tgTagLineService = {
            checkPermissions: sinon.stub()
            createColorsArray: sinon.stub()
            renderTags: sinon.stub()
        }

        provide.value "tgTagLineService", mocks.tgTagLineService


    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgTagLineService()
            return null

    beforeEach ->
        module "taigaCommon"

        _mocks()

        inject ($controller) ->
            controller = $controller

        TagLineCommonCtrl = controller "TagLineCommonCtrl"
        TagLineCommonCtrl.tags = []
        TagLineCommonCtrl.colorArray = []
        TagLineCommonCtrl.addTag = false

    it "check permissions", () ->
        TagLineCommonCtrl.project = {
        }
        TagLineCommonCtrl.project.my_permissions = [
            'permission1',
            'permission2'
        ]
        TagLineCommonCtrl.permissions = 'permissions1'

        TagLineCommonCtrl.checkPermissions()
        expect(mocks.tgTagLineService.checkPermissions).have.been.calledWith(TagLineCommonCtrl.project.my_permissions, TagLineCommonCtrl.permissions)

    it "create Colors Array", () ->
        projectTagColors = 'string'
        mocks.tgTagLineService.createColorsArray.withArgs(projectTagColors).returns(true)
        TagLineCommonCtrl._createColorsArray(projectTagColors)
        expect(TagLineCommonCtrl.colorArray).to.be.equal(true)

    it "render tags", () ->
        tags = ['tag1', 'tag2']
        project = ['project1', 'project2']
        TagLineCommonCtrl._renderTags(tags, project)
        expect(mocks.tgTagLineService.renderTags).have.been.calledWith(tags, project)

    it "display tag input", () ->
        TagLineCommonCtrl.addTag = false
        TagLineCommonCtrl.displayTagInput()
        expect(TagLineCommonCtrl.addTag).to.be.true

    it "on close tag input", () ->
        TagLineCommonCtrl.addTag = true
        event = {
            keyCode: 27
        }
        TagLineCommonCtrl.closeTagInput(event)
        expect(TagLineCommonCtrl.addTag).to.be.false

    it "on press wrong key to close tag input", () ->
        TagLineCommonCtrl.addTag = true
        event = {
            keyCode: 42
        }
        TagLineCommonCtrl.closeTagInput(event)
        expect(TagLineCommonCtrl.addTag).to.be.true

    it "on add tag", () ->
        TagLineCommonCtrl.loadingAddTag = true
        tag = 'tag1'
        tags = ['tag1', 'tag2']
        color = "CC0000"

        TagLineCommonCtrl.project = {
            tags: ['tag1', 'tag2'],
            tags_colors: ["#CC0000", "CCBB00"]
        }

        TagLineCommonCtrl.onAddTag(tag, color, TagLineCommonCtrl.project )
        expect(TagLineCommonCtrl.project.tags).to.be.eql(tags)
        expect(TagLineCommonCtrl.addTag).to.be.false
        expect(TagLineCommonCtrl.loadingAddTag).to.be.false

    it "on remove tag", () ->
        tag = 'tag1'
        TagLineCommonCtrl.project = {
            tags: ['tag1', 'tag2']
        }
        tags = ['tag2']

        TagLineCommonCtrl.onRemoveTag(tag)
        expect(TagLineCommonCtrl.project.tags).to.be.eql(tags)
        expect(TagLineCommonCtrl.loadingRemoveTag).to.be.false
