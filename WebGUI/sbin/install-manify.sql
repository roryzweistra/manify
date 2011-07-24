CREATE TABLE `Manify` (
    `assetId` char(22) binary not null,
    `templateId` char(22) binary not null,
    `categoriesTemplateId` char(22) binary not null,
    `userId` char(22) not null,
    primary key (`assetId`),
    key user_asset (`userId`, assetId`)
) ENGINE-MyISAM CHARSET=utf8;

CREATE TABLE `ManifyCategories` (
    `categoryId` char(22) binary not null,
    `userId` char(22) binary not null,
    `categoryName` char(22) binary not null,
    primary key (`categoryId`),
    key user_category (`userId`, `categoryId`),
    key user_category_name (`userId`, `categoryName`)
) ENGINE-MyISAM CHARSET=utf8;

CREATE TABLE `ManifyPlaylists` (
    `playlistId` char(22) binary not null,
    `userId` char(22) binary not null,
    `playlistName` varchar(250) not null,
    `playlistUrl` varchar(250) not null,
    `categoryId` char(22) binary not null,
    primary key (`playlistId`),
    key user_playlist (`userId`, `playlistId),
    key user_category_playlist (`userId`, `categoryId`, `playlistId`),
    key playlistname (`playlistName`)
) ENGINE-MyISAM CHARSET=utf8;