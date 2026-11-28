import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'cloudinary_service.dart';
import 'crud_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final bool showFavorites;
  final CrudService service = CrudService();
  final CloudinaryService cloudinaryService = CloudinaryService();

  HomePage({super.key, this.showFavorites = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tubera Inventory'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(showFavorites ? Icons.star : Icons.star_border),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomePage(showFavorites: !showFavorites),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final filteredDocs = showFavorites
              ? docs.where((doc) => doc.data()['isFavorite'] == true).toList()
              : docs;

          if (filteredDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    showFavorites
                        ? 'No favorite items yet'
                        : 'No items yet — tap + to add one',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data();
              final name = data['name'] as String? ?? '';
              final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
              final isFavorite = data['isFavorite'] == true;
              final imageUrl = data['image_url'] as String?;

              return Card(
                elevation: 0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: _buildLeading(context, name, imageUrl),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Cnt: $quantity'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () async {
                          try {
                            await service.setFavorite(doc.id, !isFavorite);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Could not update favorite: $e')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showItemDialog(
                          context,
                          id: doc.id,
                          name: name,
                          quantity: quantity,
                          imageUrl: imageUrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLeading(BuildContext context, String name, String? imageUrl) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    if (hasImage) {
      return GestureDetector(
        onTap: () => _showImageDialog(context, imageUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _initialAvatar(name),
          ),
        ),
      );
    }
    return _initialAvatar(name);
  }

  Widget _initialAvatar(String name) {
    return CircleAvatar(
      backgroundColor: const Color(0xFF0F766E),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 200,
                  child: Center(child: Text('Could not load image')),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemDialog(
    BuildContext context, {
    String? id,
    String name = '',
    int quantity = 0,
    String? imageUrl,
  }) async {
    final nameController = TextEditingController(text: name);
    final quantityController =
        TextEditingController(text: id == null ? '' : quantity.toString());
    File? selectedFile;
    String? existingImageUrl = imageUrl;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> pickImage() async {
            try {
              final file = await cloudinaryService.pickImage();
              if (file != null) {
                setDialogState(() {
                  selectedFile = file;
                });
              }
            } catch (e) {
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('Could not pick image: $e')),
              );
            }
          }

          Future<void> save() async {
            final trimmedName = nameController.text.trim();
            final qty = int.tryParse(quantityController.text.trim());
            if (trimmedName.isEmpty || qty == null || qty < 0) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('Enter a non-empty name and valid quantity >= 0.'),
                ),
              );
              return;
            }

            setDialogState(() {
              isSaving = true;
            });

            try {
              String? uploadedUrl;
              if (selectedFile != null) {
                uploadedUrl = await cloudinaryService.uploadImage(selectedFile!);
              }

              if (id == null) {
                await service.addItem(trimmedName, qty, imageUrl: uploadedUrl);
              } else {
                await service.updateItem(
                  id,
                  trimmedName,
                  qty,
                  imageUrl: uploadedUrl,
                );
              }

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(id == null
                      ? 'Item added successfully'
                      : 'Item updated successfully'),
                ),
              );
            } catch (e) {
              if (!dialogContext.mounted) return;
              setDialogState(() {
                isSaving = false;
              });
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('Could not save item: $e')),
              );
            }
          }

          Widget preview;
          if (selectedFile != null) {
            preview = ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                selectedFile!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            );
          } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
            preview = ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                existingImageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              ),
            );
          } else {
            preview = _imagePlaceholder();
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(id == null ? Icons.add_circle : Icons.edit,
                    color: const Color(0xFF0F766E)),
                const SizedBox(width: 8),
                Text(id == null ? 'Add Item' : 'Edit Item'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  preview,
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: isSaving ? null : pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(selectedFile != null || (existingImageUrl != null && existingImageUrl.isNotEmpty)
                        ? 'Change Image'
                        : 'Choose Image'),
                  ),
                  if (isSaving) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Uploading image to Cloudinary...'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSaving ? null : save,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(id == null ? 'Save' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await service.deleteItem(id);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully')),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not delete item: $e')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
