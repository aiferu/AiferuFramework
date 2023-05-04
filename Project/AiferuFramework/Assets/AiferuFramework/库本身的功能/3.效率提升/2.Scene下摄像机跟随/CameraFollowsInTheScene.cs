//
//  CameraFollowsInTheScene.cs
//  AiferuFramework
//
//  Created by Aiferu on 2023/5/4.
//
//
#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.PlayerLoop;

namespace AiferuFramework
{
    /// <summary>
    /// Scene下摄像机跟随
    /// </summary>
    public class CameraFollowsInTheScene 
    {
        #region Field

        #endregion

        #region Property

        #endregion

        #region UnityOriginalEvent
        

        static CameraFollowsInTheScene()
        {
            SceneView.duringSceneGui += view =>
            {
                if (Event.current.type == EventType.KeyDown)
                {
                    if (Event.current.keyCode == KeyCode.Space)
                    {
                        Debug.Log("空格按下");
                    }
                }
            };
        }
        #endregion

        #region Function

        #endregion
    }
}
#endif