package feishu

import (
	"context"
	"fmt"

	lark "github.com/larksuite/oapi-sdk-go/v3"
	larkcore "github.com/larksuite/oapi-sdk-go/v3/core"
	larkim "github.com/larksuite/oapi-sdk-go/v3/service/im/v1"
)

type AppType string
type ReceiveIdType string
type MsgType string

type ClientOptionFunc func(config *FeishuClient)

const (
	AppTypeSelfBuilt   AppType = "SelfBuilt"
	AppTypeMarketplace AppType = "Marketplace"

	ReceiveEmailId ReceiveIdType = "email"
	ReceiveOpenId  ReceiveIdType = "open_id"
	ReceiveUserId  ReceiveIdType = "user_id"
	ReceiveUnionId ReceiveIdType = "union_id"
	ReceiveChatId  ReceiveIdType = "chat_id"

	MsgTypeText        MsgType = "text"
	MsgTypePost        MsgType = "post"
	MsgTypeImage       MsgType = "image"
	MsgTypeFile        MsgType = "file"
	MsgTypeAudio       MsgType = "audio"
	MsgTypeSticker     MsgType = "sticker"
	MsgTypeInteractive MsgType = "interactive"
	MsgTypeShareChat   MsgType = "share_chat"
	MsgTypeShareUser   MsgType = "share_user"
)

type FeishuClient struct {
	appID     *string
	appSecret *string
	appType   *AppType
	client    *lark.Client
}

func WithAppType(appType AppType) func(*FeishuClient) {
	return func(client *FeishuClient) {
		client.appType = &appType
	}
}

func InitFeishu(appID, appSecret string, clients ...func(*FeishuClient)) (*FeishuClient, error) {
	client := &FeishuClient{
		appID:     &appID,
		appSecret: &appSecret,
	}
	for _, o := range clients {
		o(client)
	}

	if client.appID == nil || client.appSecret == nil || *client.appID == "" || *client.appSecret == "" {
		return nil, fmt.Errorf("appID or appSecret is empty")
	}
	if client.appType != nil && *client.appType == AppTypeMarketplace {
		client.client = lark.NewClient(*client.appID, *client.appSecret, lark.WithAppType(larkcore.AppTypeMarketplace))
	} else {
		client.client = lark.NewClient(*client.appID, *client.appSecret)
	}
	return client, nil
}

func (client *FeishuClient) SendText(content string, receiveId string, receiveIdType ReceiveIdType) error {
	feishuContent := larkim.NewTextMsgBuilder().
		Text(content).
		Build()
	req := larkim.NewCreateMessageReqBuilder().
		ReceiveIdType(string(receiveIdType)).
		Body(larkim.NewCreateMessageReqBodyBuilder().
			ReceiveId(receiveId).
			MsgType(`text`).
			Content(feishuContent).
			Build()).
		Build()
	resp, err := client.client.Im.Message.Create(context.Background(), req)
	if err != nil {
		return err
	}
	if !resp.Success() {
		return fmt.Errorf("Error code: %d, error: %s.", resp.Code, resp.Msg)
	}
	return nil
}

func (client *FeishuClient) SendMessage(content string, msgType MsgType, receiveId string, receiveIdType ReceiveIdType) error {
	req := larkim.NewCreateMessageReqBuilder().
		ReceiveIdType(string(receiveIdType)).
		Body(larkim.NewCreateMessageReqBodyBuilder().
			ReceiveId(string(receiveId)).
			MsgType(string(msgType)).
			Content(content).
			Build()).
		Build()
	resp, err := client.client.Im.Message.Create(context.Background(), req)
	if err != nil {
		return err
	}
	if !resp.Success() {
		return fmt.Errorf("Error code: %d, error: %s.", resp.Code, resp.Msg)
	}
	return nil
}
