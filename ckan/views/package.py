from flask import Blueprint
import ckan.model as model
import ckan.logic as logic
from ckan.common import _, g
import ckan.lib.base as base
import ckan.lib.helpers as h
from sqlalchemy.orm.exc import NoResultFound

package = Blueprint('package', __name__)

@package.route('/dataset/delete/<id>', methods=['POST'])
def delete_dataset(id: str):
    """Veri setini siler"""
    context = {'model': model, 'user': g.user, 'auth_user_obj': g.userobj}
    
    try:
        # Yetki kontrolü - sadece admin ve editor'ler
        package = model.Package.get(id)
        if not package:
            # Eğer veri seti bulunamadıysa ve kullanıcı sysadmin ise, zorla sil
            if g.userobj and g.userobj.sysadmin:
                # Veritabanından doğrudan silme işlemi
                model.Session.query(model.Package).filter_by(name=id).delete()
                model.Session.commit()
                h.flash_success(_('Bozuk veri seti başarıyla silindi'))
                return h.redirect_to('dataset.search')
            else:
                h.flash_error(_('Veri seti bulunamadı'))
                return h.redirect_to('dataset.search')

        organization_id = package.owner_org
        if organization_id:
            member = model.Session.query(model.Member).filter(
                model.Member.table_name == 'user',
                model.Member.state == 'active',
                model.Member.table_id == g.userobj.id,
                model.Member.group_id == organization_id
            ).first()

            if not (g.userobj.sysadmin or 
                   (member and member.capacity in ['admin', 'editor'])):
                return base.abort(403, _('Bu işlem için yetkiniz bulunmamaktadır'))
        else:
            if not g.userobj.sysadmin:
                return base.abort(403, _('Bu işlem için yetkiniz bulunmamaktadır'))

        # Veri setini sil
        context = {
            'model': model,
            'user': g.user.name,
            'ignore_auth': True
        }
        logic.get_action('package_delete')(context, {'id': id})
        
        h.flash_success(_('Veri seti başarıyla silindi'))
        return h.redirect_to('dataset.search')
        
    except logic.NotFound:
        h.flash_error(_('Veri seti bulunamadı'))
    except logic.NotAuthorized:
        h.flash_error(_('Bu işlem için yetkiniz bulunmamaktadır'))
    except Exception as e:
        h.flash_error(str(e))
    
    return h.redirect_to('dataset.read', id=id)

@package.route('/dataset/<id>', methods=['GET'])
def read(id: str):
    """Veri seti detay sayfası"""
    try:
        context = {
            'model': model,
            'session': model.Session,
            'user': g.user,
            'for_view': True,
            'auth_user_obj': g.userobj
        }
        data_dict = {'id': id}
        pkg_dict = logic.get_action('package_show')(context, data_dict)
        pkg = context['package']

        return base.render(
            'package/read.html',
            {
                'pkg_dict': pkg_dict,
                'pkg': pkg
            }
        )

    except logic.NotFound:
        if g.userobj and g.userobj.sysadmin:
            h.flash_error(_('Veri seti bulunamadı. Bu bozuk veri setini silmek için "Sil" butonunu kullanabilirsiniz.'))
        else:
            h.flash_error(_('Veri seti bulunamadı veya görüntüleme yetkiniz yok.'))
        return base.abort(404, _('Dataset not found'))
    except logic.NotAuthorized:
        h.flash_error(_('Bu veri setini görüntüleme yetkiniz yok.'))
        return base.abort(403, _('Not authorized to see this page'))
    except Exception as e:
        h.flash_error(_('Bir hata oluştu: {}').format(str(e)))
        return base.abort(500, _('Internal Server Error')) 