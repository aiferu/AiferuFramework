//
//  CircularProgressBar3.cs
//  AiferuFramework
//
//  Created by Aiferu on 2023/5/6.
//
//
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.VFX;

/// <summary>
/// ����CircularProgressBar3����
/// </summary>
public class CircularProgressBar3 : MonoBehaviour
{
    #region Field
    [SerializeField]
    [Range(0,1)]
    private float progressValue = 0;//(0-1)

    [SerializeField]
    private ParticleSystem[] particleSystems_Ring;
    [SerializeField]
    private ParticleSystem[] particleSystems_Loop;
    [SerializeField]
    private VisualEffect[] visualEffects;
    [SerializeField]
    private Text progressText;
    [SerializeField]
    private Image waterImage;

    private bool isPlaying = false;

    #endregion

    #region Property
    #endregion

    #region UnityOriginalEvent
    void Awake()
    {
        //��ʼ��
        Initialize();

    }



    void Update()
    {
        if (progressValue > 0.001f)
        {
            isPlaying = true;
        }else
        {
            isPlaying = false;
        }
        if (isPlaying)
        {
            Playing();
        }else
        {
            Idling();
        }
        
    }

 
    #endregion

    #region Function

    /// <summary>
    /// ���ý���ֵ
    /// </summary>
    /// <param name="Value">����ֵ</param>
    private void SetProgressValue(float Value)
    {
        progressValue = Value;
    }

    private void Initialize()
    {
        progressText.text = "";
        waterImage.enabled = false;
        foreach (var visualEffect in visualEffects)
        {
            visualEffect.enabled = true;
        }
        foreach (var particleSystem in particleSystems_Ring)
        {
            ParticleSystem.EmissionModule emissionModule = particleSystem.emission;
            emissionModule.rateOverTime = 0;
        }
        foreach (var particleSystem in particleSystems_Loop)
        {
            ParticleSystem.EmissionModule emissionModule = particleSystem.emission;
            emissionModule.rateOverTime = 0;
        }
    }
    private void Idling()
    {
        Initialize();
    }

    private void Playing()
    {
        progressText.text = ((int)(progressValue*100)).ToString();
        waterImage.enabled = true;
        foreach (var visualEffect in visualEffects)
        {
            visualEffect.enabled = false;
        }
        foreach (var particleSystem in particleSystems_Ring)
        {
            ParticleSystem.ShapeModule shapeModule = particleSystem.shape;
            shapeModule.arc = Mathf.Clamp(progressValue * 360, 0.1f, 360);
            ParticleSystem.EmissionModule emissionModule = particleSystem.emission;
            emissionModule.rateOverTime = 200;
        }
        foreach (var particleSystem in particleSystems_Loop)
        {
            ParticleSystem.ShapeModule shapeModule = particleSystem.shape;
            shapeModule.arc = Mathf.Clamp(progressValue * 360, 0.1f, 150);
            ParticleSystem.EmissionModule emissionModule = particleSystem.emission;
            emissionModule.rateOverTime = 70;
        }
    }
    #endregion
}
