@IsTest
public class WarehouseCalloutServiceMock implements HttpCalloutMock {
  public HttpResponse respond(HttpRequest request) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    StaticResource equipmentSource = [
      SELECT Id, Body
      FROM StaticResource
      WHERE Name = 'equipments'
    ];
    String equipmentJSON = equipmentSource.body.toString();
    System.debug('equipmentJSON' + equipmentJSON);

    response.setBody(equipmentJSON);
    response.setStatusCode(200);
    return response;
  }
}
