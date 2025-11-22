import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:festou/services/party_service.dart';
import 'package:festou/services/user_service.dart';
import 'package:festou/models/party_model.dart';
import 'package:festou/theme.dart';
import 'package:festou/widgets/party_type_selector.dart';
import 'package:festou/widgets/media_picker_widget.dart';
import 'package:festou/screens/payment_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedStyle = 'Eletrônico';
  String _partyType = 'free';
  int _premiumDays = 1;
  bool _isPremiumPaid = false;
  PlatformFile? _coverImage;
  List<PlatformFile> _mediaFiles = [];
  
  final List<String> _availableStyles = [
    'Axé',
    'Bossa Nova',
    'Carimbó',
    'Choro',
    'Eletrônico',
    'Forró',
    'Frevo',
    'Funk Brasileiro',
    'Maracatu',
    'MPB',
    'Pagode',
    'Piseiro',
    'Samba',
    'Sertanejo',
    'Tecnobrega',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _coverImage = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<void> _selectMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final totalFiles = _mediaFiles.length + result.files.length;
        if (totalFiles > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Máximo de 10 fotos/vídeos permitidos')),
            );
          }
          return;
        }
        
        for (var file in result.files) {
          final extension = file.extension?.toLowerCase();
          if (extension != null && ['mp4', 'mov', 'avi'].contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vídeos devem ter no máximo 10 segundos')),
              );
            }
          }
        }
        
        setState(() => _mediaFiles.addAll(result.files));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar mídia: $e')),
        );
      }
    }
  }

  void _removeMedia(int index) {
    setState(() => _mediaFiles.removeAt(index));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _openPaymentScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          premiumDays: _premiumDays,
          onPaymentSuccess: () {
            setState(() => _isPremiumPaid = true);
          },
        ),
      ),
    );

    if (result == true) {
      _createParty();
    }
  }

  void _createParty() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data e horário')),
      );
      return;
    }

    if (_coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma foto de capa')),
      );
      return;
    }

    final userService = context.read<UserService>();
    final partyService = context.read<PartyService>();
    final currentUser = userService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado')),
      );
      return;
    }

    if (_partyType == 'free') {
      if (!partyService.canCreateFreeParty(currentUser.lastFreePartyCreatedAt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você só pode criar uma festa gratuita a cada 30 dias. Crie uma festa premium!'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
    } else {
      if (!_isPremiumPaid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Realize o pagamento antes de criar a festa')),
        );
        return;
      }
    }
    
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    DateTime? expiresAt;
    if (_partyType == 'free') {
      expiresAt = DateTime.now().add(const Duration(days: 2));
    } else {
      expiresAt = DateTime.now().add(Duration(days: _premiumDays));
    }

    final party = PartyModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _coverImage!.path ?? 'assets/images/Night_Club_Party_null_1763753244490.jpg',
      dateTime: dateTime,
      location: _locationController.text,
      city: _cityController.text,
      latitude: -23.5505 + (0.01 * (DateTime.now().millisecondsSinceEpoch % 10)),
      longitude: -46.6333 + (0.01 * (DateTime.now().millisecondsSinceEpoch % 10)),
      style: _selectedStyle,
      price: double.tryParse(_priceController.text) ?? 0,
      organizerId: currentUser.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: _partyType,
      expiresAt: expiresAt,
      mediaUrls: _mediaFiles.map((file) => file.path ?? '').toList(),
      premiumDays: _partyType == 'premium' ? _premiumDays : 0,
      isPremiumPaid: _partyType == 'premium' ? _isPremiumPaid : false,
    );

    await partyService.addParty(party);

    if (_partyType == 'free') {
      await userService.updateUser(
        currentUser.copyWith(
          lastFreePartyCreatedAt: DateTime.now(),
        ),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _partyType == 'free' 
              ? 'Festa criada! Expira em 2 dias.' 
              : 'Festa premium criada! Expira em $_premiumDays dias.',
          ),
        ),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _cityController.clear();
      _priceController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _coverImage = null;
        _mediaFiles.clear();
        _partyType = 'free';
        _premiumDays = 1;
        _isPremiumPaid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final currentUser = userService.currentUser;
    final partyService = context.watch<PartyService>();
    final canCreateFree = partyService.canCreateFreeParty(currentUser?.lastFreePartyCreatedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Festa', style: Theme.of(context).textTheme.headlineSmall?.bold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PartyTypeSelector(
                selectedType: _partyType,
                premiumDays: _premiumDays,
                canCreateFree: canCreateFree,
                onTypeChanged: (type) => setState(() {
                  _partyType = type;
                  _isPremiumPaid = false;
                }),
                onDaysChanged: (days) => setState(() {
                  _premiumDays = days;
                  _isPremiumPaid = false;
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('Foto de Capa *', style: Theme.of(context).textTheme.titleMedium?.semiBold),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _selectCoverImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: _coverImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(_coverImage!.path!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => 
                          const Center(child: Icon(Icons.image, size: 48))),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.xs),
                          Text('Adicionar foto de capa', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              MediaPickerWidget(
                mediaFiles: _mediaFiles,
                onAddMedia: _selectMedia,
                onRemoveMedia: _removeMedia,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Festa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.celebration),
                ),
                maxLength: 140,
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                maxLength: 600,
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              
              DropdownButtonFormField<String>(
                value: _selectedStyle,
                decoration: const InputDecoration(
                  labelText: 'Estilo Musical',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.music_note),
                ),
                items: _availableStyles.map((style) => DropdownMenuItem(value: style, child: Text(style))).toList(),
                onChanged: (value) => setState(() => _selectedStyle = value!),
              ),
              const SizedBox(height: AppSpacing.md),
              
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Local',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate == null 
                          ? 'Data' 
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _selectedTime == null 
                          ? 'Hora' 
                          : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  if (double.tryParse(value!) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              
              if (_partyType == 'premium' && !_isPremiumPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openPaymentScreen,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Pagar R\$ ${(_premiumDays * 2.60).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.semiBold,
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (_partyType == 'free' || _isPremiumPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createParty,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text('Criar Festa', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                  ),
                ),
              
              if (_partyType == 'premium' && _isPremiumPaid)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Pagamento confirmado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
