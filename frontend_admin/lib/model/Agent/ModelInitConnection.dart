import '../../Util.dart';
import '../../const.dart';

class ModelInitConnection {
  final QRType qrType;
  final String agentName;
  final AgentType agentType;
  final String invitation;

  ModelInitConnection(
      {required this.agentType,
      required this.agentName,
      required this.invitation,
      required this.qrType});

  @override
  String toString() {
    return 'ModelInitConnection{agentName: $agentName, invitation: $invitation}';
  }

  static ModelInitConnection fromJson(Map<String, dynamic> data) {
    return ModelInitConnection(
        agentName: data['name'],
        invitation: data['invitation'],
        qrType: Util.strToQRType(data['qrType']),
        agentType: Util.strToAgentType(data["agentType"]));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agentName'] = agentName;
    data['invitation'] = invitation;
    switch (qrType) {
      case QRType.connectionRequest:
        data['qrType'] = "connectionRequest";
        break;
      case QRType.invalid:
        data['qrType'] = "invalid";
        break;
    }
    switch (agentType) {
      case AgentType.gov:
        data['agentType'] = "gov";
        break;
      case AgentType.multi:
        data['agentType'] = "multi";
        break;
      case AgentType.banking:
        data['agentType'] = "banking";
        break;
      case AgentType.carrier:
        data['agentType'] = "carrier";
        break;
      case AgentType.university:
        data['agentType'] = "university";
        break;
      case AgentType.invalid:
        data['agentType'] = "invalid";
        break;
    }
    return data;
  }
}
