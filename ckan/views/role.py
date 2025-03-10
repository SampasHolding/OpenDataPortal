from flask import Blueprint, request, redirect, url_for
from ckan.common import _, g
import ckan.lib.base as base
import ckan.lib.helpers as h
import ckan.logic as logic
import ckan.model as model
from typing import Dict, List, Optional, Union

role = Blueprint('role', __name__)

# Yetkiler ve açıklamaları
PERMISSIONS = {
    'create_dataset': 'Veri Seti Oluşturma',
    'edit_dataset': 'Veri Seti Düzenleme',
    'delete_dataset': 'Veri Seti Silme',
    'manage_users': 'Kullanıcı Yönetimi',
    'view_private_datasets': 'Gizli Veri Setlerini Görüntüleme',
    'manage_group': 'Grup Yönetimi',
    'manage_org_members': 'Organizasyon Üyelerini Yönetme',
    'upload_files': 'Dosya Yükleme',
    'api_access': 'API Erişimi'
}

# Rol hiyerarşisi
ROLE_HIERARCHY = {
    'Sistem Yöneticisi': ['Belediye Yöneticisi', 'Veri Yöneticisi', 'Veri Görüntüleyici'],
    'Belediye Yöneticisi': ['Veri Yöneticisi', 'Veri Görüntüleyici'],
    'Veri Yöneticisi': ['Veri Görüntüleyici'],
    'Veri Görüntüleyici': []
}

# Rol - Organizasyon Rolü eşleştirmesi
ROLE_ORG_MAPPING = {
    'Sistem Yöneticisi': 'sysadmin',
    'Belediye Yöneticisi': 'admin',
    'Veri Yöneticisi': 'editor',
    'Veri Görüntüleyici': 'member'
}

# Organizasyon Rolü - Görünen İsim eşleştirmesi
ORG_ROLE_DISPLAY = {
    'sysadmin': 'Sistem Yöneticisi',
    'admin': 'Yönetici',
    'editor': 'İçerik Düzenleyici',
    'member': 'Üye'
}

# Geçici rol listesi (veritabanına taşınacak)
roles = [
    {
        'id': 1,
        'name': 'Sistem Yöneticisi',
        'description': 'Tüm sistem yetkilerine sahiptir.',
        'permissions': list(PERMISSIONS.keys())  # Tüm yetkiler
    },
    {
        'id': 2,
        'name': 'Belediye Yöneticisi',
        'description': 'Kendi belediyesine ait verileri yönetebilir.',
        'permissions': ['create_dataset', 'edit_dataset', 'delete_dataset', 'view_private_datasets', 
                       'manage_org_members', 'upload_files', 'api_access']
    },
    {
        'id': 3,
        'name': 'Veri Yöneticisi',
        'description': 'Veri ekleme, silme ve düzenleme yetkilerine sahiptir.',
        'permissions': ['create_dataset', 'edit_dataset', 'delete_dataset', 'upload_files', 'api_access']
    },
    {
        'id': 4,
        'name': 'Veri Görüntüleyici',
        'description': 'Sadece veri görüntüleme yetkisine sahiptir.',
        'permissions': ['api_access']
    }
]

def get_role_by_id(role_id: int) -> Optional[Dict]:
    """Rol ID'sine göre rol bilgisini döndürür."""
    return next((role for role in roles if role['id'] == role_id), None)

def get_role_by_name(role_name: str) -> Optional[Dict]:
    """Rol adına göre rol bilgisini döndürür."""
    return next((role for role in roles if role['name'] == role_name), None)

def get_role_permissions(role_name: str) -> List[str]:
    """Rol adına göre yetkileri döndürür. Hiyerarşik rollerin yetkilerini de içerir."""
    role = get_role_by_name(role_name)
    if not role:
        return []
    
    permissions = set(role['permissions'])
    
    # Alt rollerin yetkilerini ekle
    for sub_role_name in ROLE_HIERARCHY.get(role_name, []):
        sub_role = get_role_by_name(sub_role_name)
        if sub_role:
            permissions.update(sub_role['permissions'])
    
    return list(permissions)

def check_org_permission(user_id: str, org_id: str, permission: str) -> bool:
    """Kullanıcının organizasyon üzerindeki yetkisini kontrol eder"""
    user = model.User.get(user_id)
    if user.sysadmin:
        return True
        
    member = model.Session.query(model.Member).filter(
        model.Member.table_name == 'user',
        model.Member.state == 'active',
        model.Member.table_id == user_id,
        model.Member.group_id == org_id
    ).first()
    
    if not member:
        return False
    
    # Üyenin rolünü bul
    role_name = ORG_ROLE_DISPLAY.get(member.capacity)
    if not role_name:
        return False
    
    # Rolün yetkilerini kontrol et
    return permission in get_role_permissions(role_name)

def get_user_org_role(user: model.User, organization_id: str) -> Optional[str]:
    """Kullanıcının organizasyondaki rolünü döndürür."""
    if not user or not organization_id:
        return None
    
    # Önce kullanıcının sistem yöneticisi olup olmadığını kontrol et
    if user.sysadmin:
        return ORG_ROLE_DISPLAY['sysadmin']
    
    member = model.Session.query(model.Member).filter(
        model.Member.table_name == 'user',
        model.Member.state == 'active',
        model.Member.table_id == user.id,
        model.Member.group_id == organization_id
    ).first()
    
    return ORG_ROLE_DISPLAY.get(member.capacity) if member else None

@role.route('/roles', methods=['GET', 'POST'])
def index():
    context = {'model': model, 'user': g.user, 'auth_user_obj': g.userobj}
    try:
        logic.check_access('sysadmin', context, {})
    except logic.NotAuthorized:
        return base.abort(403, _('Sadece sistem yöneticileri bu sayfaya erişebilir'))

    if request.method == 'POST':
        role_id = request.form.get('role_id')
        name = request.form.get('name')
        description = request.form.get('description')
        permissions = request.form.getlist('permissions')

        if role_id:  # Rol güncelleme
            role = get_role_by_id(int(role_id))
            if role:
                role['name'] = name
                role['description'] = description
                role['permissions'] = permissions
                h.flash_success(_('Rol güncellendi'))
        else:  # Yeni rol oluşturma
            new_role = {
                'id': max(r['id'] for r in roles) + 1,
                'name': name,
                'description': description,
                'permissions': permissions
            }
            roles.append(new_role)
            h.flash_success(_('Yeni rol oluşturuldu'))

    extra_vars = {
        'roles': roles,
        'permissions': PERMISSIONS,
        'role_hierarchy': ROLE_HIERARCHY
    }
    return base.render('role.html', extra_vars=extra_vars)

@role.route('/roles/update_user_role', methods=['POST'])
def update_user_role():
    """Kullanıcının sistem rolünü günceller"""
    context = {'model': model, 'user': g.user, 'auth_user_obj': g.userobj}
    try:
        logic.check_access('sysadmin', context, {})
    except logic.NotAuthorized:
        return base.abort(403, _('Sadece sistem yöneticileri kullanıcı rollerini güncelleyebilir'))

    user_id = request.form.get('user_id')
    new_role_id = request.form.get('new_role')

    if user_id and new_role_id:
        user = model.User.get(user_id)
        new_role = get_role_by_id(int(new_role_id))
        
        if user and new_role:
            # Sistem rolünü güncelle
            user.sysadmin = (new_role['name'] == 'Sistem Yöneticisi')
            model.Session.commit()
            h.flash_success(_('Kullanıcının sistem rolü güncellendi'))

    return redirect(url_for('role.index'))

@role.route('/roles/update_user_org', methods=['POST'])
def update_user_org():
    """Kullanıcının organizasyon rolünü günceller"""
    context = {'model': model, 'user': g.user, 'auth_user_obj': g.userobj}
    try:
        logic.check_access('sysadmin', context, {})
    except logic.NotAuthorized:
        return base.abort(403, _('Sadece sistem yöneticileri organizasyon ataması yapabilir'))

    user_id = request.form.get('user_id')
    org_id = request.form.get('organization')
    new_role_id = request.form.get('org_role')

    if user_id and org_id and new_role_id:
        user = model.User.get(user_id)
        new_role = get_role_by_id(int(new_role_id))
        
        if user and new_role:
            try:
                # Önce mevcut organizasyon üyeliğini kaldır
                try:
                    logic.get_action('organization_member_delete')(
                        context, {
                            'id': org_id,
                            'username': user.name
                        }
                    )
                except logic.NotFound:
                    pass  # Kullanıcı zaten organizasyonda değilse hata verme
                
                # Sistem yöneticisi rolü için özel işlem
                if new_role['name'] == 'Sistem Yöneticisi':
                    user.sysadmin = True
                    model.Session.commit()
                    org_role = 'admin'  # Organizasyonda admin olarak ayarla
                else:
                    # Diğer roller için normal süreç
                    org_role = ROLE_ORG_MAPPING.get(new_role['name'], 'member')
                
                # Organizasyona ekle
                logic.get_action('organization_member_create')(
                    context, {
                        'id': org_id,
                        'username': user.name,
                        'role': org_role
                    }
                )
                h.flash_success(_('Kullanıcının organizasyon rolü güncellendi'))
            except logic.ValidationError as e:
                h.flash_error(str(e))

    return redirect(url_for('role.index'))

@role.route('/cleanup/datasets', methods=['POST'])
def cleanup_broken_datasets():
    """404 hatası veren veri setlerini temizler"""
    context = {'model': model, 'user': g.user, 'auth_user_obj': g.userobj}
    try:
        logic.check_access('sysadmin', context, {})
    except logic.NotAuthorized:
        return base.abort(403, _('Sadece sistem yöneticileri bu işlemi yapabilir'))

    dataset_name = request.form.get('dataset_name')
    if not dataset_name:
        h.flash_error(_('Veri seti adı belirtilmedi'))
        return redirect(url_for('role.index'))

    try:
        # Veri setini bul
        dataset = model.Package.get(dataset_name)
        if not dataset:
            h.flash_error(_('Veri seti bulunamadı'))
            return redirect(url_for('role.index'))

        # Veri setini sil
        context = {
            'model': model,
            'user': g.user.name,
            'ignore_auth': True
        }
        logic.get_action('package_delete')(context, {'id': dataset.id})
        
        h.flash_success(_('Veri seti başarıyla silindi'))
    except logic.NotFound:
        h.flash_error(_('Veri seti bulunamadı'))
    except Exception as e:
        h.flash_error(str(e))

    return redirect(url_for('role.index')) 