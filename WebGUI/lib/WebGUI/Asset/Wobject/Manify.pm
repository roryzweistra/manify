package WebGUI::Asset::Wobject::Manify;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';

# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

#------------------------------------------------------------------------------------------------------------------

=head2 createCategory ( )

Adds a user specific category.

=cut

sub createCategory {
    my $self            = shift;
    my $categoryName    = $self->session->db->write( "INSERT INTO
        ManifyCategories
            ('userId', 'categoryName')
        VALUES
            (?,?)",
        [
            $self->session->userId,
            $self->session->form->param( 'categoryName' )
        ]
    );

    return $categoryName;
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
    my $i18n       = WebGUI::International->new( $session, 'Asset_NewWobject' );
    tie my %properties, 'Tie::IxHash', (
        templateId  => {
            fieldType       => "template",
            defaultValue    => 'NewWobjectTmpl00000001',
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
    my $categories  = $self->session->db->buildArrayRef( 'SELECT
            categoryName
        FROM
            ManifyCategories
        WHERE
            userId =?',
        [ $self->session->userId ]
    );

    return $categories;
}

#------------------------------------------------------------------------------------------------------------------

=head2 getEditForm ( )

returns the tabform object that will be used in generating the edit page for New Wobjects.
This method is optional if you set autoGenerateForms=1 in the definition.

=cut

sub getEditForm {
    my $self    = shift;
    my $tabform = $self->SUPER::getEditForm();

    $tabform->getTab("display")->template(
        value     => $self->getValue("templateId"),
        label     => WebGUI::International::get( "template_label", "Asset_NewWobject" ),
        namespace => "NewWobject"
    );

    return $tabform;
}

#------------------------------------------------------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new( $self->session, $self->get("templateId") );
    $template->prepare($self->getMetaDataAsTemplateVariables);
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

    #purge your wobject-specific data here.  This does not include fields
    # you create for your NewWobject asset/wobject table.
    return $self->SUPER::purge;
}

#------------------------------------------------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template to be displayed within the page style.

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;

    #This automatically creates template variables for all of your wobject's properties.
    my $var = $self->get;

    #This is an example of debugging code to help you diagnose problems.
    #$session->log->warn($self->get("templateId"));

    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

1;

#vim:ft=perl