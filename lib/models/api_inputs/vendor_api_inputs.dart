class UpdateVendorInput{
  UpdateVendorInput({
   required this.businessName,
   required this.businessCategory,
   required this.taxId,
   required this.supportContact,
});
final String businessName;
final String businessCategory;
final String taxId;
final String supportContact;

  Map<String,dynamic> toJson(){
    return {
   'businessName' :businessName,
   'businessCategory':businessCategory,
    'taxId':taxId,
    'supportContact':supportContact,
    };

  }
}