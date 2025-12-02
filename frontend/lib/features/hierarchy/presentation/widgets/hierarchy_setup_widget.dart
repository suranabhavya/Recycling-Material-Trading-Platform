import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/role_template_model.dart';

class HierarchySetupWidget extends StatefulWidget {
  final Function(String mode, List<RoleTemplateModel> roles) onHierarchyConfigured;

  const HierarchySetupWidget({
    super.key,
    required this.onHierarchyConfigured,
  });

  @override
  State<HierarchySetupWidget> createState() => _HierarchySetupWidgetState();
}

class _HierarchySetupWidgetState extends State<HierarchySetupWidget> {
  String _hierarchyMode = 'SIMPLE';
  final List<RoleTemplateModel> _roles = [];
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    // Add default admin role
    _roles.add(RoleTemplateModel(
      name: 'Admin',
      level: 1,
      permissions: {'all': true},
      requiresApproval: false,
      description: 'Top-level administrator with full permissions',
    ));
  }

  void _addRole() {
    setState(() {
      _currentLevel++;
      _roles.add(RoleTemplateModel(
        name: 'Role $_currentLevel',
        level: _currentLevel,
        permissions: {},
        requiresApproval: true,
      ));
    });
    widget.onHierarchyConfigured(_hierarchyMode, _roles);
  }

  void _removeRole(int index) {
    if (index == 0) return; // Can't remove admin
    setState(() {
      _roles.removeAt(index);
      _reorderLevels();
    });
    widget.onHierarchyConfigured(_hierarchyMode, _roles);
  }

  void _reorderLevels() {
    for (int i = 0; i < _roles.length; i++) {
      _roles[i] = _roles[i].copyWith(level: i + 1);
    }
    _currentLevel = _roles.length;
  }

  void _updateRole(int index, RoleTemplateModel role) {
    setState(() {
      _roles[index] = role;
    });
    widget.onHierarchyConfigured(_hierarchyMode, _roles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hierarchy Configuration',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Hierarchy Mode Selection
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hierarchy Mode',
                style: GoogleFonts.domine(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildModeOption('SIMPLE', 'Simple', 'Role-based hierarchy'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeOption('ADVANCED', 'Advanced', 'With org units'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Roles List
        Text(
          'Define Roles & Approval Flow',
          style: GoogleFonts.domine(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Level 1 is the highest authority. Lower levels may require approval from higher levels.',
          style: GoogleFonts.domine(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        ..._roles.asMap().entries.map((entry) {
          final index = entry.key;
          final role = entry.value;
          return _RoleCard(
            role: role,
            isAdmin: index == 0,
            onUpdate: (updated) => _updateRole(index, updated),
            onRemove: () => _removeRole(index),
          );
        }),

        const SizedBox(height: 16),

        // Add Role Button
        OutlinedButton.icon(
          onPressed: _addRole,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Role Level',
            style: GoogleFonts.domine(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(String value, String title, String subtitle) {
    final isSelected = _hierarchyMode == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _hierarchyMode = value;
        });
        widget.onHierarchyConfigured(_hierarchyMode, _roles);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.domine(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.domine(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final RoleTemplateModel role;
  final bool isAdmin;
  final Function(RoleTemplateModel) onUpdate;
  final VoidCallback onRemove;

  const _RoleCard({
    required this.role,
    required this.isAdmin,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _requiresApproval;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role.name);
    _descriptionController = TextEditingController(text: widget.role.description ?? '');
    _requiresApproval = widget.role.requiresApproval;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateRole() {
    widget.onUpdate(widget.role.copyWith(
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      requiresApproval: _requiresApproval,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isAdmin
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level ${widget.role.level}',
                  style: GoogleFonts.domine(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (!widget.isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            enabled: !widget.isAdmin,
            style: GoogleFonts.domine(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Role Name',
              labelStyle: GoogleFonts.domine(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (_) => _updateRole(),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _descriptionController,
            style: GoogleFonts.domine(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: GoogleFonts.domine(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (_) => _updateRole(),
          ),

          if (!widget.isAdmin) ...[
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(
                'Requires Approval',
                style: GoogleFonts.domine(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Materials created by this role need approval from higher levels',
                style: GoogleFonts.domine(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              value: _requiresApproval,
              onChanged: (value) {
                setState(() {
                  _requiresApproval = value ?? false;
                });
                _updateRole();
              },
              activeColor: Colors.green,
              checkColor: Colors.white,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
