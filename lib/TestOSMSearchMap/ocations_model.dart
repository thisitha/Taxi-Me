class SriLanka {
  int count;
  int nextIndex;
  int startIndex;
  int totalResults;
  List<SLLocationsModel> results;

  SriLanka({this.count, this.nextIndex, this.startIndex, this.totalResults, this.results});

  SriLanka.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    nextIndex = json['nextIndex'];
    startIndex = json['startIndex'];
    totalResults = json['totalResults'];
    if (json['results'] != null) {
      results = new List<SLLocationsModel>();
      json['results'].forEach((v) { results.add(new SLLocationsModel.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['nextIndex'] = this.nextIndex;
    data['startIndex'] = this.startIndex;
    data['totalResults'] = this.totalResults;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SLLocationsModel {
  String wikipedia;
  double rank;
  String county;
  String street;
  String wikidata;
  String countryCode;
  String osmId;
  String housenumbers;
  int id;
  String city;
  String displayName;
  double lon;
  String state;
  List<double> boundingbox;
  String type;
  double importance;
  double lat;
  String resultClass;
  String name;
  String country;
  String nameSuffix;
  String osmType;
  int placeRank;
  String alternativeNames;

  SLLocationsModel({this.wikipedia, this.rank, this.county, this.street, this.wikidata, this.countryCode, this.osmId, this.housenumbers, this.id, this.city, this.displayName, this.lon, this.state, this.boundingbox, this.type, this.importance, this.lat, this.resultClass, this.name, this.country, this.nameSuffix, this.osmType, this.placeRank, this.alternativeNames});

  SLLocationsModel.fromJson(Map<String, dynamic> json) {
  wikipedia = json['wikipedia'];
  rank = json['rank'];
  county = json['county'];
  street = json['street'];
  wikidata = json['wikidata'];
  countryCode = json['country_code'];
  osmId = json['osm_id'];
  housenumbers = json['housenumbers'];
  id = json['id'];
  city = json['city'];
  displayName = json['display_name'];
  lon = json['lon'];
  state = json['state'];
  boundingbox = json['boundingbox'].cast<double>();
  type = json['type'];
  importance = json['importance'];
  lat = json['lat'];
  resultClass = json['class'];
  name = json['name'];
  country = json['country'];
  nameSuffix = json['name_suffix'];
  osmType = json['osm_type'];
  placeRank = json['place_rank'];
  alternativeNames = json['alternative_names'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['wikipedia'] = this.wikipedia;
  data['rank'] = this.rank;
  data['county'] = this.county;
  data['street'] = this.street;
  data['wikidata'] = this.wikidata;
  data['country_code'] = this.countryCode;
  data['osm_id'] = this.osmId;
  data['housenumbers'] = this.housenumbers;
  data['id'] = this.id;
  data['city'] = this.city;
  data['display_name'] = this.displayName;
  data['lon'] = this.lon;
  data['state'] = this.state;
  data['boundingbox'] = this.boundingbox;
  data['type'] = this.type;
  data['importance'] = this.importance;
  data['lat'] = this.lat;
  data['class'] = this.resultClass;
  data['name'] = this.name;
  data['country'] = this.country;
  data['name_suffix'] = this.nameSuffix;
  data['osm_type'] = this.osmType;
  data['place_rank'] = this.placeRank;
  data['alternative_names'] = this.alternativeNames;
  return data;
  }
}
