//
//  ZoomBlur.cs
//  AiferuFramework
//
//  Created by Aiferu on 2023/5/8.
//
//
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// ZoomBlur��������ű�
/// </summary>
public class ZoomBlur : VolumeComponent, IPostProcessComponent
{

    #region Field
    [Range(0f,100f),Tooltip("��ǿЧ��ʹģ��Ч����ǿ")]
    public FloatParameter focusPower = new FloatParameter(0f);

    [Range(0, 100), Tooltip("ֵԽ��Խ��,���Ǹ��ؽ�����")]
    public IntParameter focusDetail = new IntParameter(0);

    [Tooltip("ģ�����������Ѿ�����Ļ������")]
    public Vector2Parameter focusScreenPosition = new Vector2Parameter(Vector2.zero);

    [Tooltip("�ο���ȷֱ���")]
    public IntParameter referenceResolutionx = new IntParameter(1334);
    #endregion

    #region Property

    #endregion

    #region UnityOriginalEvent

    bool IPostProcessComponent.IsActive()
    {
        return focusPower.value > 0f;
    }

    bool IPostProcessComponent.IsTileCompatible()
    {
        return false;
    }
    #endregion

    #region Function

    #endregion
}
