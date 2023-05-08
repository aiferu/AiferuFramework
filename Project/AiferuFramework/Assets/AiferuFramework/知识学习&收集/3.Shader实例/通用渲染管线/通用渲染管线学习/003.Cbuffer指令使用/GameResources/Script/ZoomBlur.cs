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
/// ZoomBlur后处理组件脚本
/// </summary>
public class ZoomBlur : VolumeComponent, IPostProcessComponent
{

    #region Field
    [Range(0f,100f),Tooltip("加强效果使模糊效果更强")]
    public FloatParameter focusPower = new FloatParameter(0f);

    [Range(0, 100), Tooltip("值越大越好,但是负载将增加")]
    public IntParameter focusDetail = new IntParameter(0);

    [Tooltip("模糊中心坐标已经在屏幕的中心")]
    public Vector2Parameter focusScreenPosition = new Vector2Parameter(Vector2.zero);

    [Tooltip("参考宽度分辨率")]
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
