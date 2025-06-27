/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//  UnifiedIdModel.swift

import Foundation

public struct UnifiedIdModel: Decodable, MdocDecodable {
	public var id: String = UUID().uuidString
	public var createdAt: Date = Date()
	public var docType: String = Self.isoDocType
	public var nameSpaces: [NameSpace]?
	public var title = String("unified_id_doctype_name")
	public static var isoDocType: String { "com.dentsusoken.vecrea.UnifiedID" }
	public static var isoNamespace: String { "org.iso.18013.5.1" }

	public var issuerSigned: IssuerSigned?
	public var devicePrivateKey: CoseKeyPrivate?
	let exp: UInt64?
	let iat: UInt64?
	public let type: String?
	public let issuer: String?
	public let service: String?
	public let userId: String?
	public let unifiedId: String?
	public let expiryDate: String?
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
	public var displayImages = [NameImage]()

	public enum CodingKeys: String, CodingKey, CaseIterable {
		case exp = "exp"
		case iat = "iat"
		case type = "type"
		case issuer = "issuer"
		case service = "service"
		case userId = "user_id"
		case unifiedId = "unified_id"
		case expiryDate = "expiry_date"
	}

    public static var isoMandatoryElementKeys: [DataElementIdentifier] { Self.isoMandatoryKeys.map(\.rawValue ) }

	public static var isoMandatoryKeys: [CodingKeys] {
		[.type, .issuer, .service, .userId, .unifiedId ]
	}
	public var mandatoryElementKeys: [DataElementIdentifier] { Self.isoMandatoryElementKeys }
}


extension UnifiedIdModel {
	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, devicePrivateKey: CoseKeyPrivate, nameSpaces: [NameSpace]? = nil) {
		self.id = id; self.createdAt = createdAt
		self.issuerSigned = issuerSigned; self.devicePrivateKey = devicePrivateKey; self.nameSpaces = nameSpaces
  	guard let nameSpaceItems = Self.getSignedItems(issuerSigned, docType, nameSpaces) else { return nil }
		Self.extractDisplayStrings(nameSpaceItems, &displayStrings, &displayImages)
		func getValue<T>(key: UnifiedIdModel.CodingKeys) -> T? { Self.getItemValue(nameSpaceItems, string: key.rawValue) }
		Self.extractAgeOverValues(nameSpaceItems, &ageOverXX)
		exp = getValue(key: .exp)
		iat = getValue(key: .iat)
		type = getValue(key: .type)
		issuer = getValue(key: .issuer)
		service = getValue(key: .service)
		userId = getValue(key: .userId)
		unifiedId = getValue(key: .unifiedId)
		expiryDate = getValue(key: .expiryDate)
	}
}
