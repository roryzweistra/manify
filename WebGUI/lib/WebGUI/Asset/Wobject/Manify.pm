package WebGUI::Asset::Wobject::Manify;

$VERSION = "1.0.0";

#------------------------------------------------------------------------------------------------------------------
# Copyright Rory Zweistra rory@oqapi.nl
#------------------------------------------------------------------------------------------------------------------
# http://www.oqapi.nl
#------------------------------------------------------------------------------------------------------------------

use strict;
use Tie::IxHash;
use JSON;
use WebGUI::International;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';

# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

#------------------------------------------------------------------------------------------------------------------

=head2 addPlaylistToCategory

Adds the playlist to a category

=cut

sub addPlaylistToCategory {
    my $self    = shift;
    my $id      = $self->session->id->generate;
    my $insert  = $self->session->db->write( "INSERT INTO
        ManifyPlaylistsCategories
            (id, playlistId, categoryId)
        VALUES
            (?,?,?)",
        [
            $id,
            $self->session->form->param( 'playlist_id' ),
            $self->session->form->param( 'category_id' ),
        ]
    );

    my $var;
    $var->{ id          } = $id;
    $var->{ playlistId  } = $self->session->form->param( 'playlist_id' );
    $var->{ categoryId  } = $self->session->form->param( 'category_id' );

    return $var;
}

#------------------------------------------------------------------------------------------------------------------

=head2 categoryForm ( )

Creates form elements for creating a new category.

=cut

sub categoryForm {
    my $self            = shift;
    my $session         = $self->session;
    my $categoryName    = shift; # Optional
    my $form;

    $form->{ formHeader     } = WebGUI::Form::formHeader( $session, {
        action  => $self->getUrl,
        extras  => 'id="category-form"'
    });

    $form->{ hidden         } = WebGUI::Form::Hidden( $session, {
        name    => 'func',
        value   => ( $categoryName ) ? 'updateCategorySave' : 'addCategorySave',
    });

    $form->{ category_name  } = WebGUI::Form::text( $session, {
        name    => 'category_name',
        value   => ( $categoryName ) ? $categoryName : '',
        size    => 50,
    });

    $form->{ submit         } = WebGUI::Form::Submit( $session, {
        name    => 'save',
        value   => 'Save',
    });

    $form->{ formFooter     } = WebGUI::Form::formFooter( $session );

    return $form;
}

#------------------------------------------------------------------------------------------------------------------

=head2 createCategory ( )

Adds a user specific category.

=cut

sub createCategory {
    my $self    = shift;
    my $id      = $self->session->id->generate;

    my $categoryName    = $self->session->db->write( "INSERT INTO
        ManifyCategories
            (categoryId, userId, categoryName)
        VALUES
            (?,?,?)",
        [
            $id,
            $self->session->user->userId,
            $self->session->form->param( 'category_name' )
        ]
    );

    my $var;
    $var->{ id      } = $id;
    $var->{ name    } = $self->session->form->param( 'category_name' );

    return $var;
}

#------------------------------------------------------------------------------------------------------------------

=head2 createPlaylist ( )

Adds a user specific playlist.

=cut

sub createPlaylist {
    my $self    = shift;
    my $id      = $self->session->id->generate;
    my $playlistName    = $self->session->db->write( "INSERT INTO
        ManifyPlaylists
            (playlistId, userId, playlistName, playlistUrl)
        VALUES
            (?,?,?,?)",
        [
            $id,
            $self->session->user->userId,
            $self->session->form->param( 'playlist_name' ),
            $self->session->form->param( 'playlist_url'  )
        ]
    );

    my $var;
    $var->{ id      } = $id;
    $var->{ name    } = $self->session->form->param( 'playlist_name' );
    $var->{ url     } = $self->session->form->param( 'playlist_url' );

    return $var;
}

#------------------------------------------------------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for New Wobject instances.  You absolutely need
this method in your new Wobjects.  If you choose to "autoGenerateForms", the
getEditForm method is unnecessary/redundant/useless.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_Manify' );
    tie my %properties, 'Tie::IxHash', (
        playlistTemplateId  => {
            fieldType       => "template",
            defaultValue    => 'hIGd_4kqwuemTaLGlUgDGg',
            tab             => "display",
            noFormPost      => 0,
            namespace       => "Manify/Playlist",
            hoverHelp       => $i18n->get( 'templateId label description'   ),
            label           => $i18n->get( 'templateId label'               ),
        },
        playlistsTemplateId  => {
            fieldType       => "template",
            defaultValue    => 'hIGd_4kqwuemTaLGlUgDGg',
            tab             => "display",
            noFormPost      => 0,
            namespace       => "Manify/Playlists",
            hoverHelp       => $i18n->get( 'templateId label description'   ),
            label           => $i18n->get( 'templateId label'               ),
        },
        categoryTemplateId  => {
            fieldType       => "template",
            defaultValue    => 'hIGd_4kqwuemTaLGlUgDGg',
            tab             => "display",
            noFormPost      => 0,
            namespace       => "Manify/Category",
            hoverHelp       => $i18n->get( 'templateId label description'   ),
            label           => $i18n->get( 'templateId label'               ),
        },
        categoriesTemplateId  => {
            fieldType       => "template",
            defaultValue    => 'hIGd_4kqwuemTaLGlUgDGg',
            tab             => "display",
            noFormPost      => 0,
            namespace       => "Manify/Categories",
            hoverHelp       => $i18n->get( 'templateId label description'   ),
            label           => $i18n->get( 'templateId label'               ),
        },
        templateId  => {
            fieldType       => "template",
            defaultValue    => 'hIGd_4kqwuemTaLGlUgDGg',
            tab             => "display",
            noFormPost      => 0,
            namespace       => "Manify",
            hoverHelp       => $i18n->get( 'templateId label description'   ),
            label           => $i18n->get( 'templateId label'               ),
        }
    );
    push @{ $definition }, {
        assetName         => $i18n->get( 'assetName' ),
        icon              => 'newWobject.gif',
        autoGenerateForms => 1,
        tableName         => 'Manify',
        className         => 'WebGUI::Asset::Wobject::Manify',
        properties        => \%properties
    };

    return $class->SUPER::definition( $session, $definition );
}

#------------------------------------------------------------------------------------------------------------------

=head2 dropCategory ( )

Remove category from category list

=cut

sub dropCategory {
    my $self        = shift;
    my $categoryId  = shift || return '0';

    my $sql = $self->session->db->write( "DELETE FROM
            ManifyCategories
        WHERE
            userId = ?
        AND
            categoryId = ?",
        [
            $self->session->user->userId,
            $categoryId
        ]
    );

    return $sql;
}

#------------------------------------------------------------------------------------------------------------------

=head2 duplicate ( )

duplicates a New Wobject.  This method is unnecessary, but if you have
auxiliary, ancillary, or "collateral" data or files related to your
wobject instances, you will need to duplicate them here.

=cut

sub duplicate {
    my $self     = shift;
    my $newAsset = $self->SUPER::duplicate( @_ );
    return $newAsset;
}

#------------------------------------------------------------------------------------------------------------------

=head2 getCategories ( )

returns all user specific categories

=cut

sub getCategories {
    my $self        = shift;
    my $categories  = $self->session->db->buildArrayRefOfHashRefs( 'SELECT
            categoryId, categoryName
        FROM
            ManifyCategories
        WHERE
            userId =?',
        [ $self->session->user->userId ]
    );

    return $categories;
}

#------------------------------------------------------------------------------------------------------------------

=head2 getPlaylists ( )

returns all user specific playlists

=cut

sub getPlaylists {
    my $self        = shift;
    my $playlists   = $self->session->db->buildArrayRefOfHashRefs( 'SELECT
            playlistId, playlistName, categoryId, playlistUrl
        FROM
            ManifyPlaylists
        WHERE
            userId =?',
        [ $self->session->user->userId ]
    );

    return $playlists;
}

#------------------------------------------------------------------------------------------------------------------

=head2 getPlaylistsForCategory ( )

returns all user specific playlists for a given category

=cut

sub getPlaylistsForCategory {
    my $self        = shift;
    my $categoryId  = $self->session->form->param( 'category_id' );
    my $playlists   = $self->session->db->buildArrayRefOfHashRefs( 'SELECT
            ManifyPlaylists.playlistId, playlistName, playlistUrl
        FROM
            ManifyPlaylists,
            ManifyPlaylistsCategories
        WHERE
            ManifyPlaylists.userId = ?
        AND
            ManifyPlaylistsCategories.categoryId = ?
        AND
            ManifyPlaylistsCategories.playlistId = ManifyPlaylists.playlistId',
        [
            $self->session->user->userId,
            $categoryId
        ]
    );

    return $playlists;
}

#------------------------------------------------------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new( $self->session, $self->get( 'templateId' ) );
    $template->prepare( $self->getMetaDataAsTemplateVariables );
    $self->{_viewTemplate} = $template;
}

#------------------------------------------------------------------------------------------------------------------

=head2 purge ( )

removes collateral data associated with a NewWobject when the system
purges it's data.  This method is unnecessary, but if you have
auxiliary, ancillary, or "collateral" data or files related to your
wobject instances, you will need to purge them here.

=cut

sub purge {
    my $self = shift;

    return $self->SUPER::purge;
}

#------------------------------------------------------------------------------------------------------------------

=head2 updateCategory ( )

Updates a user specific category.

=cut

sub updateCategory {
    my $self            = shift;
    my $categoryName    = $self->session->db->write( 'UPDATE
            ManifyCategories
        SET
            categoryName = ?
        WHERE
            categoryId = ?
        AND
            userId = ?',
        [
            $self->session->form->param( 'categoryName' ),
            $self->session->form->param( 'categoryId'   ),
            $self->session->user->userId,
        ]
    );

    return $categoryName;
}

#------------------------------------------------------------------------------------------------------------------

=head2 addPlaylistForm ( )

Creates form elements for creating a new playlist.

=cut

sub playlistForm {
    my $self            = shift;
    my $session         = $self->session;
    my $playlistName    = shift; # Optional
    my $playlistUrl     = shift; # Optional
    my $form;

    $form->{ formHeader     } = WebGUI::Form::formHeader( $session, {
        action  => $self->getUrl,
        extras  => 'id="playlist-form"'
    });

    $form->{ hidden         } = WebGUI::Form::Hidden( $session, {
        name    => 'func',
        value   => ( $playlistName ) ? 'updatePlaylistSave' : 'addPlaylistSave',
    });

    $form->{ playlist_name   } = WebGUI::Form::text( $session, {
        name    => 'playlist_name',
        value   => ( $playlistName ) ? $playlistName : '',
        size    => 50,
    });

    $form->{ playlist_url   } = WebGUI::Form::text( $session, {
        name    => 'playlist_url',
        value   => ( $playlistUrl ) ? $playlistUrl : '',
        size    => 50,
    });

    $form->{ submit         } = WebGUI::Form::Submit( $session, {
        name    => 'save',
        value   => 'Save',
    });

    $form->{ formFooter     } = WebGUI::Form::formFooter( $session );

    return $form;
}

#------------------------------------------------------------------------------------------------------------------

=head2 unlinkPlaylistsFromCategory ( )

Unlinks all the playlists from a category

=cut

sub unlinkPlaylistsFromCategory {
    my $self        = shift;
    my $categoryId  = $self->session->form->param( 'category_id' ) || return '0';

    my $sql = $self->session->db->write( 'DELETE FROM
            ManifyPlaylistsCategories
        WHERE
            categoryId = ?',
        [
            $categoryId
        ]
    );

    return $sql;
}

#------------------------------------------------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template to be displayed within the page style.

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;

    # This automatically creates template variables for all of your wobject's properties.
    my $var = $self->get;

    # A visitor should not be allowed to add categories and playlists
    if ( $session->user->isVisitor ) {
        $var->{ isVisitor } = 1;
        return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
    }

    my @categoriesLoop;
    my $categories = $self->getCategories;

    if ( $categories ) {

        foreach my $category ( @{ $categories } ) {
            push ( @categoriesLoop, {
                categoryId      => $category->{ categoryId     },
                categoryName    => $category->{ categoryName   }
            });
        }
    }
    else {
        $var->{ no_categories } = 1;
    }

    my @playlistsLoop;
    my $playlists = $self->getPlaylists;

    if ( $playlists ) {

        foreach my $playlist ( @{ $playlists } ) {
            push ( @playlistsLoop, {
                playlistId      => $playlist->{ playlistId      },
                playlistName    => $playlist->{ playlistName    },
                playlistUrl     => $playlist->{ playlistUrl     }
            });
        }
    }
    else {
        $var->{ no_playlists } = 1;
    }

    $var->{ category_loop } = \@categoriesLoop;
    $var->{ playlist_loop } = \@playlistsLoop;

    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_addCategory ( )

The www_ method for adding a new category.

=cut

sub www_addCategory {
    my $self    = shift;
    my $var     = $self->categoryForm;

    my $template    = WebGUI::Asset::Template->new( $self->session, $self->get( 'categoryTemplateId' ) );
    $template       = $template->process( $var );
    return ( $template )
        ? $template
        : 'template could not be instanciated'
    ;
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_addCategorySave ( )

www_ method that triggers the actual insertion in the database

=cut

sub www_addCategorySave {
    my $self            = shift;
    my $categoryData    = $self->createCategory;
    my $json            = JSON->new;

    return $json->encode( $categoryData );
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_getCategories ( )

The www_ method for getting the user specific categories.

=cut

sub www_getCategories {
    my $self            = shift;
    my $categories      = $self->getCategories;

    my $template    = WebGUI::Asset::Template->new( $self->session, $self->get( 'categoriesTemplateId' ) );
    $template       = $template->process( $categories );
    return ( $template )
        ? $template
        : 'template could not be instanciated'
    ;
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_getPlaylsits ( )

The www_ method for getting the user specific playlists.

=cut

sub www_getPlaylists {
    my $self            = shift;
    my $playlists      = $self->getPlaylists;

    my $template    = WebGUI::Asset::Template->new( $self->session, $self->get( 'categoriesTemplateId' ) );
    $template       = $template->process( $playlists );
    return ( $template )
        ? $template
        : 'template could not be instanciated'
    ;
}


#------------------------------------------------------------------------------------------------------------------

=head2 www_getPlaylistsForCategory ( )

The www_ method for getting the user specific playlists.

=cut

sub www_getPlaylistsForCategory {
    my $self        = shift;
    my $playlists   = $self->getPlaylistsForCategory;

    my $template    = WebGUI::Asset::Template->new( $self->session, $self->get( 'playlistsTemplateId' ) );
    $template       = $template->process( $playlists );
    return ( $template )
        ? $template
        : 'template could not be instanciated'
    ;
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_addPlaylist ( )

The www_ method for adding a new playlist.

=cut

sub www_addPlaylist {
    my $self    = shift;
    my $var     = $self->playlistForm;

    my $template    = WebGUI::Asset::Template->new( $self->session, $self->get( 'playlistTemplateId' ) );
    $template       = $template->process( $var );
    return ( $template )
        ? $template
        : 'template could not be instanciated'
    ;
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_addPlaylistSave ( )

www_ method that triggers the actual playlist insertion in the database

=cut

sub www_addPlaylistSave {
    my $self            = shift;
    my $playlistData    = $self->createPlaylist;
    my $json            = JSON->new;

    return $json->encode( $playlistData );
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_addPlaylistToCategory ( )

www_ method for adding a playlist to a category

=cut

sub www_addPlaylistToCategory {
    my $self    = shift;
    my $data    = $self->addPlaylistToCategory;
    my $json    = JSON->new;

    return $json->encode( $data );
}

#------------------------------------------------------------------------------------------------------------------

=head2 www_updateCategory ( )

The www_ method for updating a category.

=cut

sub www_updateCategory {
    my $self    = shift;
    my $id      = $self->session->form->param( 'category_id'    );
    my $name    = $self->session->form->param( 'category_name'  );
    my $var;

    # Only update the form if the id and name can be found
    if ( $id && $name ) {
        $var = $self->categoryForm( $id, $name );
    }
    else {
        $var->{ error } = 'Error';
    }

    my $template    = WebGUI::Asset::Template->new( $self->session, $self->get( 'categoryTemplateId' ) );
    $template       = $template->process( $var );
    return ( $template )
        ? $template
        : 'template could not be instanciated'
    ;
}

1;

#vim:ft=perl