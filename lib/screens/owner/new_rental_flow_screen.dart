import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/vehicle.dart';
import '../../models/customer.dart';
import '../../models/rental.dart';
import '../common/receipt_pdf_preview_screen.dart';

class NewRentalFlowScreen extends StatefulWidget {
  final Customer? prefilledCustomer;
  const NewRentalFlowScreen({super.key, this.prefilledCustomer});

  @override
  State<NewRentalFlowScreen> createState() => _NewRentalFlowScreenState();
}

class _NewRentalFlowScreenState extends State<NewRentalFlowScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  // Selected Car
  Vehicle? _selectedVehicle;

  // Step 2: Customer Fields
  final _searchCnicController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _drivingLicenceController = TextEditingController(); // OPTIONAL!

  // CNIC & Verification Images
  String? _cnicFrontPath;
  String? _cnicBackPath;
  String? _selfiePath;

  // Step 3: Rental Configuration
  int _durationDays = 3;
  final DateTime _startDate = DateTime.now();
  double _customRateOverride = 0.0;
  double _advancePayment = 20000.0;
  final String _pickupLocation = 'Main Office, Gulberg';
  final String _returnLocation = 'Main Office, Gulberg';
  final String _notes = '';

  // Step 4: Terms & Conditions Checkbox
  bool _agreementAccepted = false; // MUST NOT be pre-selected!
  DateTime? _agreementAcceptanceTime;

  // Step 5: Customer Signature, Thumb Impression & Owner Signature
  final SignatureController _customerSignatureController = SignatureController(
    penColor: Colors.black,
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _ownerSignatureController = SignatureController(
    penColor: Colors.blue.shade900,
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.white,
  );

  String? _thumbImpressionPath;
  String? _savedCustomerSignaturePath;
  String? _savedOwnerSignaturePath;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledCustomer != null) {
      _applyCustomerToFields(widget.prefilledCustomer!);
    }
  }

  void _applyCustomerToFields(Customer c) {
    _fullNameController.text = c.fullName;
    _fatherNameController.text = c.fatherName;
    _cnicController.text = c.cnicNumber;
    _mobileController.text = c.mobileNumber;
    _addressController.text = c.residentialAddress;
    _cityController.text = c.city;
    _emergencyController.text = c.emergencyContactNumber;
    _drivingLicenceController.text = c.drivingLicenceNumber ?? '';
    _cnicFrontPath = c.cnicFrontPath;
    _cnicBackPath = c.cnicBackPath;
    _selfiePath = c.selfiePath;
  }

  void _lookupCustomerByCnic() {
    final cnic = _searchCnicController.text.trim();
    if (cnic.isEmpty) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final found = provider.findCustomerByCnic(cnic);
    if (found != null) {
      _applyCustomerToFields(found);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Returning Customer Found: ${found.fullName}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No previous record found. Please fill new customer details.')));
    }
  }

  Future<void> _pickCnicImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (isFront) {
          _cnicFrontPath = image.path;
        } else {
          _cnicBackPath = image.path;
        }
      });
    }
  }

  Future<void> _captureLiveSelfie() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (image != null) {
      setState(() => _selfiePath = image.path);
    }
  }

  Future<void> _captureThumbImpression() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _thumbImpressionPath = image.path);
    }
  }

  Future<String?> _saveSignatureToFile(SignatureController controller, String prefix) async {
    if (controller.isEmpty) return null;
    final bytes = await controller.toPngBytes();
    if (bytes != null) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    }
    return null;
  }

  Widget _buildCarImage(String path, {double size = 50}) {
    bool isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.car_rental, size: 28),
        ),
      );
    } else {
      return Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.car_rental, size: 28),
        ),
      );
    }
  }

  bool _validateStep() {
    if (_currentStep == 0) {
      if (_selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an available vehicle.')));
        return false;
      }
      return true;
    } else if (_currentStep == 1) {
      if (_fullNameController.text.isEmpty ||
          _fatherNameController.text.isEmpty ||
          _cnicController.text.isEmpty ||
          _mobileController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all mandatory customer information fields.')));
        return false;
      }
      return true;
    } else if (_currentStep == 3) {
      if (!_agreementAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must check and accept the Terms and Conditions before proceeding.'), backgroundColor: Colors.red),
        );
        return false;
      }
      return true;
    } else if (_currentStep == 4) {
      if (_customerSignatureController.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer digital signature is required.')));
        return false;
      }
      if (_thumbImpressionPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer thumb impression capture is required.')));
        return false;
      }
      if (_ownerSignatureController.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Owner / Authorized Person signature is required.')));
        return false;
      }
      return true;
    }
    return true;
  }

  void _submitAndGenerateRental() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    // Save Signatures
    _savedCustomerSignaturePath = await _saveSignatureToFile(_customerSignatureController, 'cust_sig');
    _savedOwnerSignaturePath = await _saveSignatureToFile(_ownerSignatureController, 'owner_sig');

    // Save/Update Customer
    final customer = Customer(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _fullNameController.text,
      fatherName: _fatherNameController.text,
      cnicNumber: _cnicController.text,
      mobileNumber: _mobileController.text,
      residentialAddress: _addressController.text,
      city: _cityController.text,
      emergencyContactNumber: _emergencyController.text,
      drivingLicenceNumber: _drivingLicenceController.text.isEmpty ? null : _drivingLicenceController.text,
      cnicFrontPath: _cnicFrontPath,
      cnicBackPath: _cnicBackPath,
      selfiePath: _selfiePath,
      registrationDate: DateTime.now(),
    );

    final savedCustomer = provider.saveOrUpdateCustomer(customer);

    double rate = _customRateOverride > 0 ? _customRateOverride : _selectedVehicle!.dailyPrice;
    double totalRentalCost = rate * _durationDays;
    double remaining = (totalRentalCost + _selectedVehicle!.securityDeposit) - _advancePayment;

    String rentalId = 'RNT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final rental = Rental(
      rentalId: rentalId,
      customerId: savedCustomer.id,
      customerName: savedCustomer.fullName,
      customerCnic: savedCustomer.cnicNumber,
      customerMobile: savedCustomer.mobileNumber,
      vehicleId: _selectedVehicle!.id,
      vehicleName: _selectedVehicle!.name,
      vehicleRegistrationNumber: _selectedVehicle!.registrationNumber,
      startDate: _startDate,
      originalReturnDate: _startDate.add(Duration(days: _durationDays)),
      currentReturnDate: _startDate.add(Duration(days: _durationDays)),
      durationDays: _durationDays,
      dailyRate: rate,
      totalRentalCharges: totalRentalCost,
      securityDeposit: _selectedVehicle!.securityDeposit,
      advancePayment: _advancePayment,
      remainingBalance: remaining,
      pickupLocation: _pickupLocation,
      returnLocation: _returnLocation,
      notes: _notes,
      cnicFrontPath: _cnicFrontPath,
      cnicBackPath: _cnicBackPath,
      selfiePath: _selfiePath,
      signatureImagePath: _savedCustomerSignaturePath,
      thumbImpressionPath: _thumbImpressionPath,
      ownerSignatureImagePath: _savedOwnerSignaturePath,
      creationDate: DateTime.now(),
    );

    provider.createRental(rental);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPdfPreviewScreen(rental: rental)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final availableCars = provider.vehicles.where((v) => v.status == VehicleStatus.available).toList();

    double effectiveRate = _selectedVehicle != null
        ? (_customRateOverride > 0 ? _customRateOverride : _selectedVehicle!.dailyPrice)
        : 0.0;
    double calculatedTotal = effectiveRate * _durationDays;
    double securityDep = _selectedVehicle?.securityDeposit ?? 0.0;
    double netTotal = calculatedTotal + securityDep;
    double remainingBal = netTotal - _advancePayment;

    return Scaffold(
      appBar: AppBar(title: Text('New Rental Agreement: Step ${_currentStep + 1} of 5')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_validateStep()) {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else {
              _submitAndGenerateRental();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 4 ? 'Save & Generate Agreement' : 'Continue'),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Select Available Vehicle
          Step(
            title: const Text('Step 1: Select Vehicle'),
            content: availableCars.isEmpty
                ? const Text('No available cars in inventory right now. Please free or add a car first.', style: TextStyle(color: Colors.red))
                : Column(
                    children: availableCars.map((car) {
                      bool isSelected = _selectedVehicle?.id == car.id;
                      String firstImg = car.imageUrls.isNotEmpty ? car.imageUrls.first : '';

                      return Card(
                        color: isSelected ? Colors.blue.shade50 : null,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _buildCarImage(firstImg, size: 50),
                          ),
                          title: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Reg: ${car.registrationNumber}\nPKR ${car.dailyPrice.toStringAsFixed(0)}/day | Deposit: PKR ${car.securityDeposit.toStringAsFixed(0)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                          onTap: () => setState(() => _selectedVehicle = car),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          // Step 2: Customer Information & CNIC / Selfie Uploads
          Step(
            title: const Text('Step 2: Customer Info & Documents'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCnicController,
                          decoration: const InputDecoration(labelText: 'Search Returning Customer by CNIC', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _lookupCustomerByCnic,
                        child: const Text('Auto-Fill'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'Customer Full Name *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _fatherNameController, decoration: const InputDecoration(labelText: "Father's Name *", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _cnicController, decoration: const InputDecoration(labelText: 'CNIC Number *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile Number *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Residential Address *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _emergencyController, decoration: const InputDecoration(labelText: 'Emergency Contact Number', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: _drivingLicenceController,
                  decoration: const InputDecoration(
                    labelText: 'Driving Licence Number (OPTIONAL)',
                    hintText: 'Optional - Can be left blank',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('CNIC & Verification Document Images:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            _cnicFrontPath != null
                                ? Image.file(File(_cnicFrontPath!), height: 75, width: 90, fit: BoxFit.cover)
                                : Container(height: 75, width: 90, color: Colors.grey.shade200, child: const Icon(Icons.badge, size: 32)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: OutlinedButton(
                                onPressed: () => _pickCnicImage(true),
                                child: Text(_cnicFrontPath != null ? 'Retake Front' : 'CNIC Front'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            _cnicBackPath != null
                                ? Image.file(File(_cnicBackPath!), height: 75, width: 90, fit: BoxFit.cover)
                                : Container(height: 75, width: 90, color: Colors.grey.shade200, child: const Icon(Icons.badge, size: 32)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: OutlinedButton(
                                onPressed: () => _pickCnicImage(false),
                                child: Text(_cnicBackPath != null ? 'Retake Back' : 'CNIC Back'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: Column(
                          children: [
                            _selfiePath != null
                                ? Image.file(File(_selfiePath!), height: 75, width: 90, fit: BoxFit.cover)
                                : Container(height: 75, width: 90, color: Colors.grey.shade200, child: const Icon(Icons.camera_front, size: 32)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: OutlinedButton(
                                onPressed: _captureLiveSelfie,
                                child: Text(_selfiePath != null ? 'Retake Selfie' : 'Live Selfie'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Step 3: Duration & Financials
          Step(
            title: const Text('Step 3: Duration & Financial Charges'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('Rental Duration (Days):')),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if (_durationDays > 1) _durationDays--; })),
                        Text('$_durationDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _durationDays++)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Custom Daily Rate Override (PKR)',
                    hintText: 'Default: PKR ${_selectedVehicle?.dailyPrice.toStringAsFixed(0) ?? "0"}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _customRateOverride = double.tryParse(val) ?? 0.0),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: _advancePayment.toStringAsFixed(0)),
                  decoration: const InputDecoration(labelText: 'Advance Payment Recieved (PKR)', border: OutlineInputBorder()),
                  onChanged: (val) => setState(() => _advancePayment = double.tryParse(val) ?? 0.0),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Daily Rate:'), Flexible(child: Text('PKR ${effectiveRate.toStringAsFixed(0)}', textAlign: TextAlign.right, overflow: TextOverflow.ellipsis))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Duration Charges ($_durationDays Days):'), Flexible(child: Text('PKR ${calculatedTotal.toStringAsFixed(0)}', textAlign: TextAlign.right, overflow: TextOverflow.ellipsis))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Security Deposit:'), Flexible(child: Text('PKR ${securityDep.toStringAsFixed(0)}', textAlign: TextAlign.right, overflow: TextOverflow.ellipsis))]),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Advance Payment Paid:'), Flexible(child: Text('-PKR ${_advancePayment.toStringAsFixed(0)}', textAlign: TextAlign.right, overflow: TextOverflow.ellipsis))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Remaining Balance Due:'), Flexible(child: Text('PKR ${remainingBal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis))]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Step 4: Terms and Conditions & Mandatory Acceptance Checkbox
          Step(
            title: const Text('Step 4: Terms & Conditions Acceptance'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CUSTOMER AGREEMENT - TERMS AND CONDITIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
                const SizedBox(height: 8),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      '1. Closing Time\nThe customer must collect their belongings and complete the required formalities before the designated closing time.\n\n'
                      '2. Customer Responsibility\nCustomers are responsible for following the establishment\'s rules and instructions. Any failure to comply with these conditions may result in action by management.\n\n'
                      '3. Personal Belongings\nCustomers are responsible for taking care of their personal belongings. Management\'s responsibility for lost or damaged items will be subject to the applicable rules and conditions.\n\n'
                      '4. Compliance with Instructions\nCustomers must follow all instructions issued by management and authorized staff.\n\n'
                      '5. Use of Facilities\nCustomers must use the facilities responsibly and comply with the rules established for their use.\n\n'
                      '6. Management Instructions\nCustomers must follow any additional instructions issued by management regarding the use of the premises.\n\n'
                      '7. Responsibility for Damage\nCustomers may be held responsible for damage caused through negligence or misuse of the facilities.\n\n'
                      '8. Rules and Regulations\nAll customers must comply with the rules and regulations of the establishment.\n\n'
                      '9. Extension of Time\nAny extension of the permitted time will be subject to management\'s approval and the applicable charges.\n\n'
                      '10. Penalty\nA penalty of Rs. 1,000 may apply in the circumstances specified by the establishment\'s rules.\n\n'
                      '11. Additional Charges\nAdditional charges may apply where the customer fails to comply with the applicable conditions.\n\n'
                      '12. Customer Conduct\nCustomers must maintain appropriate conduct and follow the instructions of management while on the premises.\n\n'
                      '13. Closing and Additional Time Charges\nThe closing time is 5:00 AM. Customers who remain beyond the permitted time may be charged for additional time.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Customer Declaration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    '"I confirm that I have read and understood the above Terms and Conditions and agree to comply with the rules and regulations of the establishment."',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.blueAccent,
                  title: const Text(
                    'I have read and understood the Terms and Conditions and agree to them as a legally binding agreement. *',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  value: _agreementAccepted,
                  onChanged: (val) {
                    setState(() {
                      _agreementAccepted = val ?? false;
                      if (_agreementAccepted) {
                        _agreementAcceptanceTime = DateTime.now();
                      }
                    });
                  },
                ),
                if (_agreementAcceptanceTime != null)
                  Text(
                    'Accepted on: ${_agreementAcceptanceTime!.toLocal().toString().split('.')[0]}',
                    style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          // Step 5: Digital Signatures & Submission
          Step(
            title: const Text('Step 5: Signatures & Final Submission'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Digital Signature *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Customer signs directly on screen using finger:'),
                const SizedBox(height: 8),
                Container(
                  height: 140,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Signature(
                    controller: _customerSignatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Customer Signature'),
                    onPressed: () => _customerSignatureController.clear(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Customer Thumb Impression Capture *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Center(
                  child: Column(
                    children: [
                      _thumbImpressionPath != null
                          ? Image.file(File(_thumbImpressionPath!), height: 100, width: 100, fit: BoxFit.cover)
                          : Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.fingerprint, size: 40, color: Colors.grey),
                            ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_thumbImpressionPath != null ? 'Retake Thumb Impression' : 'Capture Thumb Impression'),
                        onPressed: _captureThumbImpression,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Owner / Authorized Person Signature *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent)),
                const SizedBox(height: 4),
                const Text('Owner signs directly on screen below:'),
                const SizedBox(height: 8),
                Container(
                  height: 140,
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade300)),
                  child: Signature(
                    controller: _ownerSignatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Owner Signature'),
                    onPressed: () => _ownerSignatureController.clear(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
