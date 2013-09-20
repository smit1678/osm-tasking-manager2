# -*- coding: utf-8 -*-
<%inherit file="base.mako"/>
<%block name="header">
<a href="${request.route_url('home')}" class="brand"><i class="icon-home"></i></a>
<div class="brand">${project.name}</div>
</%block>
<%block name="content">
<%
import markdown
%>
<%
from geoalchemy2 import shape
from geoalchemy2.functions import ST_Centroid
geometry_as_shape = shape.to_shape(project.area.geometry)
centroid = geometry_as_shape.centroid
left = (centroid.x + 180) * 120 / 360 - 1
top = (-centroid.y + 90) * 60 / 180 - 1
%>
<%
# FIXME already done in base.mako
from pyramid.security import authenticated_userid
from osmtm.models import DBSession, User
username = authenticated_userid(request)
if username is not None:
   user = DBSession.query(User).get(username)
else:
   user = None
%>
<div class="container">
  <div class="row">
    <div class="span12">
      <ul class="nav nav-pills">
          <li class="active"><a href="#main" data-toggle="tab">${_('Info')}</a>
        </li>
        <li><a id="map_tab" href="#map" data-toggle="tab">${_('Contribute')}</a>
        </li>
        % if user and user.is_admin():
        <a class="btn pull-right" href="${request.route_url('project_edit', project=project.id)}">
          <i class="icon-edit"></i> Edit
        </a>
        % endif
      </ul>
    </div>
  </div>
</div>
<div class="tab-content">
  <div id="main" class="tab-pane active container">
    <div class="span6">
      <div class="page-header">
        <h4>${_('Description')}</h4>
      </div>
      <p>${markdown.markdown(project.description)|n}</p>
    </div>
    <div class="span5">
      <div class="world_map">
        <div class="marker" style="top:${top}px;left:${left}px"></div>
      </div>
      <div class="page-header">
        <h4>${_('Activity')}</h4>
      </div>
      <%include file="task.history.mako" args="section='project'"/>
    </div>
  </div>
  <div id="map" class="tab-pane">
    <div id="leaflet"></div>
    <div id="right-col">
      <p id="task_loading" class="alert alert-success hide">
        ${_('Loading')}
      </p>
      <p id="task_msg" class="alert alert-success hide"></p>
      <div id="task_empty">
        <%include file="task.empty.mako" />
      </div>
      <div id="task" class="row-fluid">
      </div>
    </div>
  </div>
  <script src="${request.static_url('osmtm:static/js/lib/leaflet.js')}"></script>
  <script src="${request.static_url('osmtm:static/js/lib/Leaflet.utfgrid/dist/leaflet.utfgrid.js')}"></script>
  <script>
<%
from shapely.wkb import loads
from geojson import Feature, FeatureCollection, dumps
geometry = loads(str(project.area.geometry.data))
%>
var project_id = ${project.id};
var geometry = ${dumps(geometry)|n};
var base_url = "${request.route_url('home')}";
</script>
  <script type="text/javascript" src="${request.static_url('osmtm:static/js/project.js')}"></script>
</div>
</%block>